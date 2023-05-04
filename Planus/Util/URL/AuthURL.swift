//
//  AuthURL.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

struct KakaoAuthURL {
    static let kakaoAuthCodeURL = "https://kauth.kakao.com/oauth/authorize?client_id=e3db77b879bd944542d59883a7d1f448&redirect_uri=\(redirectURI)&response_type=code"
    static let redirectURI = "http://localhost:8080/app/oauth/kakao"
}

struct GoogleAuthURL {
    static let googleAuthCodeURL = "https://accounts.google.com/o/oauth2/v2/auth?client_id=7772745345-82ah7rvqp7fttqh3eaoih7el6rtikvqu.apps.googleusercontent.com&redirect_uri=\(Self.redirectURI)&response_type=code&scope=profile+email"
    static let redirectURI = "http://localhost:8080/app/oauth/google"
}

struct WebViewCustomUserAgent {
    static let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1"
}

