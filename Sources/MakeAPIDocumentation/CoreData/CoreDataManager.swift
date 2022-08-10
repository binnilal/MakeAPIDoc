//
//  CoreDataManager.swift
//  hanaApp
//
//  Created by Lehana on 27/07/2022.
//

import Foundation
import CoreData
public enum PresistenceStoreType {
    case binary
    // FOR NSBinaryStoreType
    
    case inMemory
    // FOR NSInMemoryStoreType
    
    case sqLite
    // FOR NSSQLiteStoreType
    
    var stringValue: String {
        switch self {
        case .binary:
            return NSBinaryStoreType
        case .inMemory:
            return NSInMemoryStoreType
            
        case .sqLite:
            return NSSQLiteStoreType
        }
    }
}
public protocol DataManagerErrorLogger {
    func log(error: NSError, file: StaticString, function: StaticString, line: UInt)
}
private class DefaultErrorLogger: DataManagerErrorLogger{
    func log(error: NSError, file: StaticString, function: StaticString, line: UInt) {
        fatalError("[\(file) - function \(function) - line - \(line)] Error - \(error.localizedDescription)")
    }
}
private struct CoreDataConstants {
    static fileprivate let mustCallSetupMethodErrorMessage = "Must Call Setup Function"
}
public class CoreDataManager {
    private static var dataModelName: String?
    private static var dataModelBundle: Bundle?
    private static var persistentStoreName: String?
    private static var persistentStoreType = PresistenceStoreType.sqLite
    public static var fetchBatchSize = 0
    public static var errorLogger: DataManagerErrorLogger? = DefaultErrorLogger()
    
    public static func setUp(withDataModel dataModelName: String, presistentStoreName: String, presistentStoryType: PresistenceStoreType = .sqLite) {
        CoreDataManager.dataModelName =  dataModelName
        CoreDataManager.dataModelBundle =  Bundle(identifier: "com.binni.MakeAPIDocumentation")
        CoreDataManager.persistentStoreName =  presistentStoreName
        CoreDataManager.persistentStoreType =  presistentStoryType
    }
    private static var applicationDocumentDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    private static var managedObjectModel: NSManagedObjectModel = {
        guard let dataModelName = CoreDataManager.dataModelName else{
            fatalError("Atempting to use nil data model name \(CoreDataConstants.mustCallSetupMethodErrorMessage)")
        }
        guard let modelURL = CoreDataManager.dataModelBundle?.url(forResource: CoreDataManager.dataModelName, withExtension: "momd") else {
            fatalError("Failed to locate data model schema file")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else{
            fatalError("Failed to create managed object model")
        }
        return managedObjectModel
    }()
    static let persistentStoreCoordinate: NSPersistentStoreCoordinator = {
        guard let persistentStoreName = CoreDataManager.persistentStoreName else{
            fatalError("Atempting to use nil persistent store name \(CoreDataConstants.mustCallSetupMethodErrorMessage)")
        }
        let coordinates = NSPersistentStoreCoordinator(
            managedObjectModel: CoreDataManager.managedObjectModel
        )
        let url = CoreDataManager.applicationDocumentDirectory.appendingPathComponent("\(persistentStoreName).sqlite")
        print(url)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        do{
            try coordinates.addPersistentStore(ofType: CoreDataManager.persistentStoreType.stringValue, configurationName: nil, at: url, options: options)
        }  catch let error as NSError {
            print("Failed to initialize the application persistent data: \(error.localizedDescription)")
        }
        catch {
            print("Failed to initialize the application persistent data")
        }
        
        return coordinates
    }()
    static var privateContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataManager.persistentStoreCoordinate
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    static var mainContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = CoreDataManager.privateContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    public static func createChildContext(withParent parent: NSManagedObjectContext)
    -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = parent
        return context
    }
    public static func fetchObjects<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchBatchSize = fetchBatchSize
        do {
            return try context.fetch(request)
        } catch let error as NSError {
            log(error: error)
            return [T]()
        }
    }
    public static func fetchObject<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext) -> T? {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch let error as NSError {
            log(error: error)
            return nil
        }
    }
    public static func delete(_ objects: [NSManagedObject], in context: NSManagedObjectContext){
        for object in objects {
            context.delete(object)
        }
    }
    public static func deleteAllObjects(){
        for entity in managedObjectModel.entitiesByName.keys {
            let request = NSFetchRequest<NSManagedObject>(entityName: entity)
            request.includesPropertyValues = false
            do {
                for object in try mainContext.fetch(request){
                    mainContext.delete(object)
                }
            } catch let error as NSError {
                log(error: error)
            }
        }
    }
    private static func log(error: NSError,
                            function: StaticString = #function,
                            file: StaticString = #file,
                            line: UInt = #line){
        errorLogger?.log(error: error, file: file, function: function, line: line)
    }
    public static func persist(synchronously: Bool, completion: ((NSError?) -> Void)? = nil){
        var mainContextSaveError: NSError?
        if mainContext.hasChanges{
            mainContext.performAndWait{
                do {
                    try self.mainContext.save()
                }
                catch let error as NSError {
                    mainContextSaveError = error
                }
            }
        }
        guard mainContextSaveError == nil else {
            completion?(mainContextSaveError)
            return
        }
        func savePrivateContext(){
            do {
                try privateContext.save()
                completion?(nil)
            }
            catch let error as NSError {
                completion?(error)
            }
        }
        if privateContext.hasChanges{
            if synchronously{
                privateContext.performAndWait(savePrivateContext)
            }else{
                privateContext.perform(savePrivateContext)
            }
        }
    }
    
    static func getAllRestAPIs() -> [CDNetworkData] {
        let fetchAllStories = CoreDataManager.fetchObjects(entity: CDNetworkData.self,
                                                           predicate: nil,
                                                           sortDescriptors: nil,
                                                           context: CoreDataManager.mainContext)
        return fetchAllStories
    }
    
    static func getRestAPI(ofName name: String, url: String) -> CDNetworkData? {
        let predicate1 = NSPredicate(format: "\(#keyPath(CDNetworkData.name)) == %@", name)
        let predicate2 = NSPredicate(format: "\(#keyPath(CDNetworkData.url)) = %@", url)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        let fetchAllStories = CoreDataManager.fetchObjects(entity: CDNetworkData.self,
                                                           predicate: andPredicate,
                                                           sortDescriptors: nil,
                                                           context: CoreDataManager.mainContext)
        return fetchAllStories.count > 0 ? fetchAllStories[0] : nil
    }
    
    static func saveRestAPI(ofAPI restApi: RestAPIData) {
        if let name = restApi.name, let url = restApi.url, let savedAPI = CoreDataManager.getRestAPI(ofName: name, url: url) {
            if let request = restApi.request, request != "" {
                savedAPI.request = request
            }
            if let response = restApi.response, response != "" {
                savedAPI.response = response
            }
        } else {
            _ = CDNetworkData(context: CoreDataManager.mainContext, apiData: restApi)
        }
        CoreDataManager.persist(synchronously: true) { error in
            print(error?.localizedDescription)
        }
    }
    
    static func saveRestAPIs(ofAPIs restApis: [RestAPIData]) {
        for api in restApis {
            _ = CDNetworkData(context: CoreDataManager.mainContext, apiData: api)
        }
        CoreDataManager.persist(synchronously: true) { error in
            print(error?.localizedDescription)
        }
    }
}

