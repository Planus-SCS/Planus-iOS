//
//  SocialAuthRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

class DefaultSocialAuthRepository: SocialAuthRepository {
    
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func kakaoSignIn(code: String) -> Single<Data> {
        let endPoint = APIEndPoint(
            url: KakaoAuthURL.kakaoSignInURL,
            requestType: .get,
            body: nil,
            query: ["code": code],
            header: nil
        )
        
        return apiProvider.requestData(endPoint: endPoint)
    }
    
    func googleSignIn(code: String) -> Single<Data> {
        let endPoint = APIEndPoint(
            url: GoogleAuthURL.googleSignInURL,
            requestType: .get,
            body: nil,
            query: ["code": code],
            header: nil
        )
        
        return apiProvider.requestData(endPoint: endPoint)
    }
    
    func appleSignIn() {
        
    }
}
