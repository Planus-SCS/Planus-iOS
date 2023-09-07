//
//  DefaultFCMRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/09/07.
//

import Foundation
import RxSwift

class DefaultFCMRepository: FCMRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func patchFCMToken(token: String, fcmToken: String) -> Single<ResponseDTO<FCMTokenResponseDTO>> {
        let dto = FCMTokenRequestDTO(fcmToken: fcmToken)
        
        let endPoint = APIEndPoint(
            url: BaseURL.main + URLPathComponent.app + "/fcm-token",
            requestType: .patch,
            body: dto,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<FCMTokenResponseDTO>.self
        )
    }
}
