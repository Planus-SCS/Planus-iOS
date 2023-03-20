//
//  DefaultNetworkManager.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation
import RxSwift

class DefaultNetworkManager: NetworkManager {
    
    func requestCodable<T: Codable>(endPoint: ApiEndPoint, type: T.Type) -> Single<T> {
        return requestData(endPoint: endPoint).map { data in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
    
    func requestData(endPoint: ApiEndPoint) -> Single<Data> {
        
        return Single<Data>.create { [weak self] emitter in
            guard let self else { return }
            var request: URLRequest
            do {
                request = try self.createRequest(endPoint: endPoint)
            } catch {
                emitter(.failure(error))
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    emitter(.failure(error))
                    return
                }
                
                guard let data = data else {
                    emitter(.failure(NetworkError.nilDataError))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else { return }
                
                switch httpResponse.statusCode {
                case (200..<300):
                    emitter(.success(data))
                case (300..<400):
                    emitter(.failure(NetworkError.unKnownError(String("300~400"))))
                case (400..<500):
                    emitter(.failure(NetworkError.unKnownError(String("400~500"))))
                default:
                    emitter(.failure(NetworkError.unKnownError()))
                }
            }
            task.resume()
            return Disposables.create() {
                task.cancel()
            }
            
        }
        
    }
}

private extension DefaultNetworkManager {
    private func createRequest(endPoint: ApiEndPoint) throws -> URLRequest {
        
        guard var urlComponents = URLComponents(string: endPoint.url) else {
            throw NetworkError.invalidURLFormatError
        }
        
        if let query = endPoint.query {
            var queryItems = [URLQueryItem]()
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURLFormatError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.requestType.rawValue
        
        if let body = endPoint.body {
            guard let data = try? JSONEncoder().encode(body) else {
                throw NetworkError.httpBodyEncodingError
            }
            request.httpBody = data
        }
        
        if let header = endPoint.header {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
