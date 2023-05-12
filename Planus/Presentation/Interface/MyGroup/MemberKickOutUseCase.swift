//
//  MemberKickOutUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/13.
//

import Foundation
import RxSwift
protocol MemberKickOutUseCase {
    var didKickOutMemberAt: PublishSubject<(Int, Int)> { get }
    func execute(token: Token, groupId: Int, memberId: Int) -> Single<Void>
}
