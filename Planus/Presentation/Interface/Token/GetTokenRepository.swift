//
//  DefaultGetTokenRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

protocol GetTokenUseCase {
    func execute() -> Single<Token>
}
