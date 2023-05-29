//
//  FetchSearchResultUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/27.
//

import Foundation
import RxSwift

protocol FetchSearchResultUseCase {
    func execute(token: Token, keyWord: String, page: Int, size: Int) -> Single<[UnJoinedGroupSummary]>
}
