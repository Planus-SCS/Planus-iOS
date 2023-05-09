//
//  TokenRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

protocol TokenRepository {
    func refresh() -> Single<ResponseDTO<TokenRefreshResponseDataDTO>>?
    func get() -> Token?
    func set(token: Token)
    func delete()
}
