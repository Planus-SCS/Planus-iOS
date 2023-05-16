//
//  DefaultFetchMemberCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

class DefaultFetchMemberCategoryUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute() -> Single<[Category]> {
        
    }
}
