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

    let memoryCache = NSCache<NSString, CacheWrapper<Data>>()
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func fetch(key: String) -> Single<Data> {
        if let wrappedCache = memoryCache.object(forKey: NSString(string: key)),
           wrappedCache.value.isImageData {
            let data = wrappedCache.value
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
