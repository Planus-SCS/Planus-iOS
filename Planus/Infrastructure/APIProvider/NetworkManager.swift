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
        let request = try! createRequest(endPoint: endPoint)
        return self.request(request: request)
    }
    
    func requestMultipartCodable<T: Codable>(endPoint: APIMultiPartEndPoint, type: T.Type) -> Single<T> {
        return requestMultipartData(endPoint: endPoint).map { data in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
    
    func requestMultipartData(endPoint: APIMultiPartEndPoint) -> Single<Data> {
        let request = try! createMultiPartRequest(endPoint: endPoint)
        return self.request(request: request)
    }
    
    func request(request: URLRequest) -> Single<Data> {
        return Single<Data>.create { [weak self] emitter -> Disposable in
            guard let self else {
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    emitter(.failure(error))
                    return
                }
                
                guard let data = data else {
                    emitter(.failure(NetworkManagerError.nilDataError))
                    return
                }
                
//                DispatchQueue.main.async {
//                    print(request.url)
//                    if let body = request.httpBody {
//                        print(String(data: body, encoding: .utf8))
//                    }
//
                    print(String(data: data, encoding: .utf8))
//                }

                guard let httpResponse = response as? HTTPURLResponse else { return }
                switch httpResponse.statusCode {
                case (200..<300):
                    emitter(.success(data))
                case (300..<400):
                    let message = (try? JSONDecoder().decode(FailureDTO.self, from: data))?.message
                    emitter(.failure(NetworkManagerError.redirection(httpResponse.statusCode, message)))
                case 401:
                    emitter(.failure(NetworkManagerError.tokenExpired))
                case (400..<500):
                    let message = (try? JSONDecoder().decode(FailureDTO.self, from: data))?.message
                    emitter(.failure(NetworkManagerError.clientError(httpResponse.statusCode, message)))
                case (500..<600):
                    let message = (try? JSONDecoder().decode(FailureDTO.self, from: data))?.message
                    emitter(.failure(NetworkManagerError.serverError(httpResponse.statusCode, message)))
                default:
                    let message = (try? JSONDecoder().decode(FailureDTO.self, from: data))?.message
                    emitter(.failure(NetworkManagerError.unKnownError(httpResponse.statusCode, message)))
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
            throw NetworkManagerError.invalidURLFormatError
        }
        
        if let query = endPoint.query {
            var queryItems = [URLQueryItem]()
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkManagerError.invalidURLFormatError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.requestType.rawValue
        
        if let body = endPoint.body {
            guard let data = try? JSONEncoder().encode(body) else {
                throw NetworkManagerError.httpBodyEncodingError
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
    
    private func createMultiPartRequest(endPoint: APIMultiPartEndPoint) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: endPoint.url) else {
            throw NetworkManagerError.invalidURLFormatError
        }
        
        if let query = endPoint.query {
            var queryItems = [URLQueryItem]()
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkManagerError.invalidURLFormatError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.requestType.rawValue

        let boundary = UUID().uuidString
        let bodyData = createMultiPartData(boundary: boundary, param: endPoint.body, imageList: endPoint.image)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        if let header = endPoint.header {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
    
    private func createMultiPartData(boundary: String, param: [String: Codable]?, imageList: [String: ImageFile]?) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)"

        if let imageList = imageList {
            for (key, image) in imageList {
                body.append("\(boundaryPrefix)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(image.filename).\(image.type)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/\(image.type)\r\n\r\n".data(using: .utf8)!)
                body.append(image.data)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        if let param = param {
            for (key, value) in param {
                guard let data = try? JSONEncoder().encode(value) else { continue }
                body.append("\(boundaryPrefix)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
                body.append("\(String(decoding: data, as: UTF8.self))\r\n".data(using: .utf8)!)
            }
        }
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        return body
    }
}
