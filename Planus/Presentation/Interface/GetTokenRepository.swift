//
//  DefaultGetTokenRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation

protocol GetTokenUseCase {
    func execute() -> Token?
}
