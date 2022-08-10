//
//  CDNetworkData+CoreDataProperties.swift
//  NetworkRequestResponse
//
//  Created by Tawakal Express on 06/08/2022.
//

import Foundation
import CoreData


extension CDNetworkData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDNetworkData> {
        return NSFetchRequest<CDNetworkData>(entityName: "CDNetworkData")
    }
    @NSManaged public var header: String?
    @NSManaged public var name: String?
    @NSManaged public var request: String?
    @NSManaged public var requestType: String?
    @NSManaged public var response: String?
    @NSManaged public var url: String?
}

extension CDNetworkData : Identifiable {
    
}
