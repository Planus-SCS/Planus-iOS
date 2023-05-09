//
//  GroupCreateUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

protocol GroupCreateUseCase {
    func execute(token: Token, groupCreate: GroupCreate, image: ImageFile) -> Single<Void>
}