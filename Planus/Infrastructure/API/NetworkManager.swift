//
//  NetworkManager.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

class NetworkManager: APIProvider {
    
    func requestCodable<T: Codable>(endPoint: APIEndPoint, type: T.Type) -> Single<T> {
        return requestData(endPoint: endPoint).map { data in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
    
    func requestData(endPoint: APIEndPoint) -> Single<Data> {
        
        return Single<Data>.create { [weak self] emitter -> Disposable in
            guard let self else {
                return Disposables.create()
            }
            
            var request: URLRequest
            do {
                request = try self.createRequest(endPoint: endPoint)
            } catch {
                emitter(.failure(error))
                return Disposables.create()
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
                case 401:
                    emitter(.failure(TokenError.tokenExpired))
                case (400..<500):
                    emitter(.failure(NetworkError.unKnownError(String("400~500"))))
                default:
                    emitter(.failure(NetworkError.unKnownError(String("400~500"))))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
        
    }
}

private extension NetworkManager {
    private func createRequest(endPoint: APIEndPoint) throws -> URLRequest {
        
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
