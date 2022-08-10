//
//  ServiceEnum.swift
//  MakeAPIDocumentation
//
//  Created by Tawakal Express on 08/08/2022.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public enum HTTPTask {
    case requestPlain
    case requestParameters(Parameters)
    case upload(Data)
}

public enum ParametersEncoding {
    case url
    case json
    case data
}

public enum NetworkError: Error {
    case decoding
    case unknown
    case noConnectivity
    case noData
        // Add more cases upto our usecase
    
    var localizedDescription: String {
        switch self {
        case .decoding: return "Decoding error"
        case .unknown: return "Unknown error"
        case .noConnectivity: return "No Connectivity"
        case .noData: return "No Data"
        }
    }
}
