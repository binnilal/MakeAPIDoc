//
//  Services.swift
//  MakeAPIDocumentation
//
//  Created by Tawakal Express on 08/08/2022.
//

import UIKit

public typealias Headers = [String: String]
public typealias Parameters = [String: Any]

public protocol ServiceProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: Headers? { get }
    var parametersEncoding: ParametersEncoding { get }
}
