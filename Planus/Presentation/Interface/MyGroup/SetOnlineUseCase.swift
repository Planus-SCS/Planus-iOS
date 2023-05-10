//
//  SetOnlineUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation

protocol SetOnlineUseCase {
    func execute(token: Token, groupId: Int) -> Single<Void>
}
