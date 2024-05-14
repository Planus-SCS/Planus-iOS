//
//  KeyValueStorage.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/13.
//

import Foundation

protocol PersistantKeyValueStorage {
    func set(key: String, value: Any)
    func get(key: String) -> Any?
    func remove(key: String)
}
