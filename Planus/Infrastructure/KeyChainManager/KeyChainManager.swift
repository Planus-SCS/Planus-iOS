//
//  KeyChainManager.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

class KeyChainManager {
    func set(key: String, value: Any) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: value
        ]
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        assert(status == noErr, "\(key): \(value) 저장 실패")
    }
    
    func get(key: String) -> Any? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,  // CFData 타입으로 불러오라는 의미
            kSecMatchLimit: kSecMatchLimitOne       // 중복되는 경우, 하나의 값만 불러오라는 의미
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef
        } else {
            print("failed to loading, status code = \(status)")
            return nil
        }
    }
    
    func delete(key: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query)
        assert(status == noErr, "failed to delete the value, status code = \(status)")
    }
}
