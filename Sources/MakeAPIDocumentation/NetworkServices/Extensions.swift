//
//  Extensions.swift
//  Network
//

import Foundation

extension URLComponents {

    init(service: ServiceProtocol) {
        let url = service.baseURL.appendingPathComponent(service.path)
        self.init(url: url, resolvingAgainstBaseURL: false)!
        guard case let .requestParameters(parameters) = service.task, service.parametersEncoding == .url else { return }
        queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: String(describing: value))
        }
    }
}

extension URLRequest {

    init(service: ServiceProtocol) {
        let urlComponents = URLComponents(service: service)
        print("URL: \(urlComponents.url!.absoluteString)")
        self.init(url: urlComponents.url!)
        httpMethod = service.method.rawValue
        print(urlComponents.url!)
        service.headers?.forEach { key, value in
            addValue(value, forHTTPHeaderField: key)
        }
        if case let .upload(data) = service.task, service.parametersEncoding == .data {
            httpBody = data
            return
        }
        if case let .requestParameters(parameters) = service.task, service.parametersEncoding == .json {
            let data = try? JSONSerialization.data(withJSONObject: parameters)
            if let data1 = data, let jsonStr = String(data: data1, encoding: .utf8) {
                print(jsonStr)
                CommonAPICapture.shared.captureAPI(service: service, request: jsonStr, response: nil)
            }
            httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            return
        }
    }
}

class CommonAPICapture {
    static let shared: CommonAPICapture = CommonAPICapture()
    
    init() {
    }
    
    func captureAPI(service: ServiceProtocol, request: String?, response: String?) {
        guard BNMakeAPIDoc.shared.isEnableAPIDocShareButton else {
            return
        }
        let url  = service.baseURL.absoluteString + service.path
        let name = String(describing: service)
        let type = service.method.rawValue
        var requestString: String  = ""
        var responseString: String = ""
        var headerString: String   = ""
        
        if let request1 = request {
            requestString = request1
        }
        if let response1 = response {
            responseString = response1
        }
        if let header = service.headers {
            headerString = header.description
        }
        
        let restAPIData = RestAPIData(header: headerString, name: name, request: requestString, requestType: type, response: responseString, url: url)
        BNMakeAPIDoc.shared.saveRestAPI(ofAPI: restAPIData)
    }
}
