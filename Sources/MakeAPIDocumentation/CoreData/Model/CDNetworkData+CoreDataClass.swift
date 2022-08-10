//
//  CDNetworkData+CoreDataClass.swift
//  NetworkRequestResponse
//
//  Created by Tawakal Express on 06/08/2022.
//

import Foundation
import CoreData


public class CDNetworkData: NSManagedObject {
    convenience init(context: NSManagedObjectContext, apiData: RestAPIData) {
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: "\(CDNetworkData.self)"), in: context) else {
            fatalError("Unable to name entity \(String(describing: "\(CDNetworkData.self)"))")
        }
        self.init(entity: entity, insertInto: context)
        self.header      = apiData.header
        self.name        = apiData.name
        if let request = apiData.request, request != "" {
            self.request = apiData.request
        }
        if let response = apiData.response, response != "" {
            self.response = apiData.response
        }
        self.requestType = apiData.requestType
        self.url         = apiData.url
    }
}
