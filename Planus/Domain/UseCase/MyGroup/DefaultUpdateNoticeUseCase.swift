//
//  DefaultUpdateNoticeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

class DefaultUpdateNoticeUseCase: UpdateNoticeUseCase {
    static let shared = DefaultUpdateNoticeUseCase(myGroupRepository: DefaultMyGroupRepository(apiProvider: NetworkManager()))
    let myGroupRepository: MyGroupRepository
    
    var didUpdateNotice = PublishSubject<GroupNotice>()
    
    private init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupNotice: GroupNotice) -> Single<Void> {
        myGroupRepository
            .updateNotice(
                token: token.accessToken,
                groupId: groupNotice.groupId,
                notice: MyGroupNoticeEditRequestDTO(notice: groupNotice.notice)
            )
            .map { [weak self] _ in
                self?.didUpdateNotice.onNext(groupNotice)
                return ()
            }
    }
}
