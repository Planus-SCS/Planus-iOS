//
//  FetchTodoListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

protocol ReadTodoListUseCase {
    func execute(token: Token, from: Date, to: Date) -> Single<[Date: [Todo]]>
}
