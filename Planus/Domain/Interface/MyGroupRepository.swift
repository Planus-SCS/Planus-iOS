//
//  MyGroupRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

protocol MyGroupRepository {
    func create(token: String, groupCreateRequestDTO: GroupCreateRequestDTO, image: ImageFile) -> Single<ResponseDTO<GroupCreateResponseDTO>>
    func fetchJoinApplyList(token: String) -> Single<ResponseDTO<[GroupJoinAppliedResponseDTO]>>
    func acceptApply(token: String, applyId: Int) -> Single<ResponseDTO<GroupJoinAcceptResponseDTO>>
    func denyApply(token: String, applyId: Int) -> Single<ResponseDTO<GroupJoinRejectResponseDTO>>
}
