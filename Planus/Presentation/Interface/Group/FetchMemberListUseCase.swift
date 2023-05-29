//
//  FetchMemberListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

protocol FetchMemberListUseCase {
    func execute(token: Token, groupId: Int) -> Single<[Member]>
}
