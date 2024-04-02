//
//  DefaultUpdateNoticeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

final class DefaultUpdateNoticeUseCase: UpdateNoticeUseCase {

    let myGroupRepository: MyGroupRepository
    let didUpdateNotice = PublishSubject<GroupNotice>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupNotice: GroupNotice) -> Single<Void> {
        myGroupRepository
            .updateNotice(
                token: token.accessToken,
                groupId: groupNotice.groupId,
                notice: MyGroupNoticeEditRequestDTO(notice: groupNotice.notice)
            )
            .do(onSuccess: { [weak self] _ in
                self?.didUpdateNotice.onNext(groupNotice)
            })
            .map { _ in
                return ()
            }
    }
}
