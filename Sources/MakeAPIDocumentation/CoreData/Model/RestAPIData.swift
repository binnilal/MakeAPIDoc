//
//  RestAPIData.swift
//  NetworkRequestResponse
//
//  Created by Tawakal Express on 06/08/2022.
//

import Foundation

public class RestAPIData {
    
    var header: String?
    var name: String?
    var request: String?
    var requestType: String?
    var response: String?
    var url: String?
    
    public init(header: String?, name: String?, request: String?, requestType: String?, response: String?, url: String?) {
        self.header      = header
        self.name        = name
        self.request     = request
        self.requestType = requestType
        self.response    = response
        self.url         = url
    }
}
