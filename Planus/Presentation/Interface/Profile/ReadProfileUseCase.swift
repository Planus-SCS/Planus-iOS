//
//  ReadProfileUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

protocol ReadProfileUseCase {
    func execute(token: Token) -> Single<Profile>
}
