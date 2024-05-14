//
//  CacheWrapper.swift
//  Planus
//
//  Created by Sangmin Lee on 5/15/24.
//

import Foundation

class CacheWrapper<T>: NSObject {
    let value: T
    
    init(_ `struct`: T) {
        value = `struct`
    }
}
