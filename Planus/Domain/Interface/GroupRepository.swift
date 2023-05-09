//
//  GroupRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

protocol GroupRepository {
    func fetchGroup(token: String, id: Int) -> Single<ResponseDTO<UnJoinedGroupDetailResponseDTO>>
    func fetchMemberList(token: String, id: Int) -> Single<ResponseDTO<[MemberDTO]>>
}
