//
//  UpdateNoticeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

protocol UpdateNoticeUseCase {
    func execute(token: Token, groupId: Int, notice: String) -> Single<Void>
}
