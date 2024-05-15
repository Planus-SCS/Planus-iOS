//
//  UserDefaultsManager.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/13.
//

import Foundation

final class UserDefaultsManager: PersistantKeyValueStorage {
    func set(key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func get(key: String) -> Any? {
        let value = UserDefaults.standard.object(forKey: key)
        return value
    }
    
    func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
