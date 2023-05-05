//
//  URLPool.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/04.
//

import Foundation

struct URLPool {
    typealias Base = BaseURL
    typealias Path = URLPathComponent
    
    static let todo = Base.main + Path.app + Path.todos
    static let calendar = Base.main + Path.app + Path.todos + Path.calendar
    static let categories = Base.main + Path.app + Path.categories
    static let refreshToken = Base.main + Path.app + Path.auth + Path.tokenReissue
    static let oauthKakao = Base.main + Path.app + Path.oauth + Path.kakao
    static let oauthGoogle = Base.main + Path.app + Path.oauth + Path.google
}