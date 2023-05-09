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
}
