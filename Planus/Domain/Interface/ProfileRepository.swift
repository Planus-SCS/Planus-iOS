//
//  ProfileRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

protocol ProfileRepository {
    func readProfile(token: String) -> Single<ResponseDTO<ProfileResponseDataDTO>>
    func updateProfile(token: String, requestDTO: ProfileRequestDTO, profileImage: ImageFile?) -> Single<ResponseDTO<ProfileResponseDataDTO>>
    func removeProfile(token: String) -> Single<ResponseDTO<ProfileResponseDataDTO>>
}
