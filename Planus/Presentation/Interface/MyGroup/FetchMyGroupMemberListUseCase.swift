//
//  FetchMyGroupMemberListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

protocol FetchMyGroupMemberListUseCase {
    func execute(token: Token, groupId: Int) -> Single<[MyGroupMemberProfile]>
}
