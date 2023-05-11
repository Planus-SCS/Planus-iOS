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
            // 이 Single을 만든 클로저가 다시실행되는거니까,,, 클래스를 만들던 해서 여기에서 불러와야함,,,,,,,,
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    emitter(.failure(error))
                    return
                }
                
                guard let data = data else {
                    emitter(.failure(NetworkError.nilDataError))
                    return
                }
                let str = String(decoding: data, as: UTF8.self)
                if str.count < 1000 {
                    print(str)
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
    
    private func createMultiPartRequest(endPoint: APIMultiPartEndPoint) throws -> URLRequest {
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
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(image.filename).png\"\r\n".data(using: .utf8)!)
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
