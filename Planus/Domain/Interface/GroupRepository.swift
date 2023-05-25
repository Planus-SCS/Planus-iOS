//
//  GroupRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

protocol GroupRepository {
    func fetchSearchHome(token: String, page: Int, size: Int) -> Single<ResponseDTO<[UnJoinedGroupSummaryResponseDTO]>>
    func fetchGroupDetail(token: String, id: Int) -> Single<ResponseDTO<UnJoinedGroupDetailResponseDTO>>
    func fetchMemberList(token: String, id: Int) -> Single<ResponseDTO<[MemberDTO]>>
    func joinGroup(token: String, id: Int) -> Single<ResponseDTO<GroupJoinApplingResponseDTO>>
}
