//
//  Provider.swift
//  Network

import Foundation

protocol ProviderProtocol {
    func request<T, U: RawRepresentable>(type: T.Type, service: U, strategy: JSONDecoder.KeyDecodingStrategy, completion: @escaping (Result<T, NetworkError>) -> ()) where T: Decodable, U:ServiceProtocol
}

public final class BNAPIProvider: ProviderProtocol {
    
    public static var shared: BNAPIProvider = BNAPIProvider()
    
    private var session: URLSessionProtocol

    private init() { self.session = URLSession.shared }
    
    public func request<T, U>(type: T.Type, service: U, strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase, completion: @escaping (Result<T, NetworkError>) -> ()) where T: Decodable, U: ServiceProtocol & RawRepresentable {
        let request = URLRequest(service: service)
        let task = session.dataTask(request: request, completionHandler: { [weak self] data, response, error in
            if let dataa = data, let responseJson = String(data: dataa, encoding: .utf8) {
                CommonAPICapture.shared.captureAPI(service: service, request: nil, response: responseJson)
            }
            let httpResponse = response as? HTTPURLResponse
            self?.handleDataResponse(data: data, response: httpResponse, error: error, strategy: strategy, completion: completion)
        })
        task.resume()
    }
    
    func downloadRequest<T: ServiceProtocol & RawRepresentable>(service: T, completion: @escaping (Result<URL?, NetworkError>) -> ()) {
        let request = URLRequest(service: service)
        let task = session.dataTask(request: request) { data, response, error in
            guard error == nil else { return completion(.failure(.noConnectivity)) }
            guard let _ = response else { return completion(.failure(.noData)) }
            let temporaryDirectoryUrl = FileManager.default.temporaryDirectory
            do {
                try data!.write(to: temporaryDirectoryUrl)
                completion(.success(temporaryDirectoryUrl))
            } catch {
                completion(.failure(.unknown))
            }
        }
        task.resume()
    }
    
    private func handleDataResponse<T: Decodable>(data: Data?, response: HTTPURLResponse?, error: Error?, strategy: JSONDecoder.KeyDecodingStrategy, completion: (Result<T, NetworkError>) -> ()) {
        guard error == nil else { return completion(.failure(.noConnectivity)) }
        guard let response = response else { return completion(.failure(.noData)) }
        switch response.statusCode {
        case 200...299:
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = strategy
            guard let data = data else { return completion(.failure(.noData)) }
            guard let model = try? jsonDecoder.decode(T.self, from: data) else { return completion(.failure(.decoding)) }
            completion(.success(model))
        default: completion(.failure(.unknown))
        }
    }
}
