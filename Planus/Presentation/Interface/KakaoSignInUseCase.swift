//
//  KakaoSignInUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

protocol KakaoSignInUseCase {
    func execute() -> Observable<String>?
}
