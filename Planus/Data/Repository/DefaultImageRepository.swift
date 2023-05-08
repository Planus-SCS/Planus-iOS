//
//  DefaultImageRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

class CacheWrapper<T>: NSObject {
    let value: T
    
    init(_ `struct`: T) {
        value = `struct`
    }
}

class DefaultImageRepository: ImageRepository {
    // 필요한거: 메모리 캐싱, 로컬 캐싱, api
    static let shared = DefaultImageRepository(apiProvider: NetworkManager())
    
    let memoryCache = NSCache<NSString, CacheWrapper<Data>>()
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func fetch(key: String) -> Single<Data> {
        if let wrappedCache = memoryCache.object(forKey: NSString(string: key)) {
            let data = wrappedCache.value
            print("캐시된거씀")
            return Single.just(data)
        }
        
        let endPoint = APIEndPoint(
            url: key,
            requestType: .get,
            body: nil,
            query: nil,
            header: nil
        )
        return apiProvider
            .requestData(endPoint: endPoint)
            .map { [weak self] data in
                self?.memoryCache.setObject(
                    CacheWrapper(data),
                    forKey: NSString(string: key)
                )
                return data
            }
    }
}