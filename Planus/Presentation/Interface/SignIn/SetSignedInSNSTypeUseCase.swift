//
//  SetSignedInSNSTypeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/13.
//

import Foundation

protocol SetSignedInSNSTypeUseCase {
    func execute(type: SocialAuthType)
}
