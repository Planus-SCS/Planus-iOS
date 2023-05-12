//
//  DefaultUpdateNoticeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

class DefaultUpdateNoticeUseCase: UpdateNoticeUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int, notice: String) -> Single<Void> {
        myGroupRepository
            .updateNotice(
                token: token.accessToken,
                groupId: groupId,
                notice: MyGroupNoticeEditRequestDTO(notice: notice)
            )
            .map { _ in () }
    }
}
