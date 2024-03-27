//
//  GenerateGroupLinkUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/30.
//

import Foundation

protocol GenerateGroupLinkUseCase {
    func execute(groupId: Int) -> String
}
