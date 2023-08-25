//
//  GetSignedInSNSTypeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/13.
//

import Foundation

protocol GetSignedInSNSTypeUseCase {
    func execute() -> SocialAuthType?
}
