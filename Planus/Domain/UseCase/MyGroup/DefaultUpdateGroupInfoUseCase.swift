//
//  DefaultUpdateGroupInfoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import Foundation
import RxSwift

class DefaultUpdateGroupInfoUseCase: UpdateGroupInfoUseCase {
    let myGroupRepository: MyGroupRepository
    
    var didUpdateInfo = PublishSubject<(Int, [String], Int, ImageFile)>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(
        token: Token,
        groupId: Int,
        tagList: [String],
        limit: Int,
        image: ImageFile
    ) -> Single<Void> {
        return myGroupRepository
            .updateInfo(
                token: token.accessToken,
                groupId: groupId,
                editRequestDTO: MyGroupInfoEditRequestDTO(tagList: tagList.map { GroupTagRequestDTO(name: $0) }, limitCount: limit),
                image: image
            )
            .map { [weak self] _ in
                self?.didUpdateInfo.onNext((groupId, tagList, limit, image))
                return ()
                
            }
    }
}
