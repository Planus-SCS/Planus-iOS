//
//  DefaultImageRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

final class DefaultImageRepository: ImageRepository {

    private let memoryCache = NSCache<NSString, CacheWrapper<Data>>()
    
    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL
    private let maxDiskCacheSize: UInt64 = 100 * 1024 * 1024 // 디스크 캐시 최대 100 메가바이트
    
    private let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
        diskCacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")
        createDiskCacheDirectoryIfNeeded()
    }
    
    func fetch(key: String) -> Single<Data> {
        if let memoryData = fetchMemoryCache(forKey: key) {
            return Single.just(memoryData)
        }
        
        if let diskData = fetchDiskCache(forKey: key) {
            return Single.just(diskData)
        }
        
        return fetchAPI(forKey: key)
    }
}

// MARK: FileManager 초기셋팅
private extension DefaultImageRepository {
    func createDiskCacheDirectoryIfNeeded() {
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
}

// MARK: Fetch
private extension DefaultImageRepository {
    private func fetchMemoryCache(forKey key: String) -> Data? {
        if let wrappedCache = memoryCache.object(forKey: NSString(string: key)),
           wrappedCache.value.isImageData {
            return wrappedCache.value
        }
        return nil
    }
    
    private func fetchDiskCache(forKey key: String) -> Data? {
        guard let fileName = URL(string: key)?.lastPathComponent else { return nil }
        let fileURL = diskCacheDirectory.appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: fileURL) {
            updateModificationDate(fileURL: fileURL)
            
            cacheImageToMemory(data, forKey: key)
            return data
        }
        return nil
    }
    
    private func fetchAPI(forKey key: String) -> Single<Data> {
        let endPoint = APIEndPoint(
            url: key,
            requestType: .get,
            body: nil,
            query: nil,
            header: nil
        )
        
        return apiProvider
            .request(endPoint: endPoint)
            .do { [weak self] data in
                self?.cacheImageToMemory(data, forKey: key)
                self?.cacheImageToDisk(data, forKey: key)
            }
    }
}

// MARK: 캐싱 로직
private extension DefaultImageRepository {
    func cacheImageToDisk(_ data: Data, forKey key: String) {
        guard let fileName = URL(string: key)?.lastPathComponent else { return }
        let fileURL = diskCacheDirectory.appendingPathComponent(fileName)
        
        try? data.write(to: fileURL)
        checkDiskCacheSize()
    }
    
    func cacheImageToMemory(_ data: Data, forKey key: String) {
        memoryCache.setObject(
            CacheWrapper(data),
            forKey: NSString(string: key)
        )
    }
}

// MARK: 디스크 캐싱 정책 관련 로직
private extension DefaultImageRepository {
    func updateModificationDate(fileURL: URL) {
        guard var attribute = try? fileManager.attributesOfItem(atPath: fileURL.path) else { return }
        attribute[.modificationDate] = Date()
        try? fileManager.setAttributes(attribute, ofItemAtPath: fileURL.path)
    }
    
    func checkDiskCacheSize() {
        guard let diskCacheContents = try? fileManager.contentsOfDirectory(
            at: diskCacheDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return
        }
        
        let totalSize: UInt64 = diskCacheContents.reduce(0) { result, fileURL in
            let fileAttributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
            if let fileSize = fileAttributes?[.size] as? UInt64 {
                return result + fileSize
            }
            return result
        }

        if totalSize > maxDiskCacheSize {
            removeOldDiskCache(totalSize - maxDiskCacheSize)
        }
    }

    func removeOldDiskCache(_ bytesToFree: UInt64) {
        guard let diskCacheContents = try? fileManager.contentsOfDirectory(
            at: diskCacheDirectory,
            includingPropertiesForKeys: []
        ) else {
            return
        }
        
        // MARK: LRU
        let sortedFiles = diskCacheContents.sorted { file1, file2 in
            if let date1 = try? fileManager.attributesOfItem(atPath: file1.path)[.modificationDate] as? Date,
               let date2 = try? fileManager.attributesOfItem(atPath: file2.path)[.modificationDate] as? Date {
                return date1.compare(date2) == .orderedAscending
            }
            return false
        }

        var bytesFreed: UInt64 = 0
        for fileURL in sortedFiles {
            if let fileSize = try? fileManager.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64 {
                try? fileManager.removeItem(at: fileURL)
                bytesFreed += fileSize
                
                if bytesFreed >= bytesToFree {
                    break
                }
            }
        }
    }
}
