//
//  FCMRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/09/07.
//

import Foundation
import RxSwift

protocol FCMRepository {
    func patchFCMToken(token: String, fcmToken: String) -> Single<ResponseDTO<FCMTokenResponseDTO>>
}
