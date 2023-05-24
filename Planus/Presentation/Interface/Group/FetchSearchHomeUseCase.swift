//
//  FetchSearchHomeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/24.
//

import Foundation
import RxSwift

protocol FetchSearchHomeUseCase {
    func execute(page: Int, size: Int) -> Single<[UnJoinedGroupSummary]>
}
