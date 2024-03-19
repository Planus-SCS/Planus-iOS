//
//  FetchUnJoinedGroupUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

protocol FetchUnJoinedGroupUseCase {
    func execute(token: Token, id: Int) -> Single<GroupDetail>
}
