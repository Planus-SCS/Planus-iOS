//
//  ProfileRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

protocol ProfileRepository {
    func readProfile(token: Token) -> Single<ResponseDTO<ProfileResponseDataDTO>>
}
