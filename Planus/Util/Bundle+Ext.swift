//
//  Bundle+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 4/3/24.
//

import Foundation

extension Bundle {
    var baseURL: String {
        guard let file = self.path(forResource: "PrivacyList", ofType: "plist") else { fatalError("PrivacyList.plist 파일이 없습니다.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("파일 형식 에러") }
        guard let key = resource["baseURL"] as? String else { fatalError("PrivacyList에 baseURL을 설정해주세요.")}
        return key
    }
    
    var appleSignInNonce: String {
        guard let file = self.path(forResource: "PrivacyList", ofType: "plist") else { fatalError("PrivacyList.plist 파일이 없습니다.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("파일 형식 에러") }
        guard let key = resource["AppleSignInNonce"] as? String else { fatalError("PrivacyList에 AppleSignInNonce을 설정해주세요.")}
        return key
    }
}
