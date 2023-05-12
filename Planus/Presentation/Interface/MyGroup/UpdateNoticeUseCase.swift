//
//  UpdateNoticeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

protocol UpdateNoticeUseCase {
    var didUpdateNotice: PublishSubject<GroupNotice> { get }
    func execute(token: Token, groupNotice: GroupNotice) -> Single<Void>
    
}
