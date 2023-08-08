//
//  SetOnlineUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

protocol SetOnlineUseCase {
    var didChangeOnlineState: PublishSubject<(Int, Int)> { get }
    func execute(token: Token, groupId: Int) -> Single<Void>
}
