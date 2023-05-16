//
//  MemberCalendarRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

protocol MemberCalendarRepository {
    func fetchMemberTodoList(
        token: String,
        groupId: Int,
        memberId: Int,
        from: Date,
        to: Date
    ) -> Single<ResponseDTO<[TodoEntityResponseDTO]>>
    
    func fetchMemberCategoryList(
        token: String,
        groupId: Int,
        memberId: Int
    ) -> Single<ResponseDTO<[CategoryEntityResponseDTO]>>
}
