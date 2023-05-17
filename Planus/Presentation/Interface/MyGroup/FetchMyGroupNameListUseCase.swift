//
//  FetchMyGroupNameListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/17.
//

import Foundation
import RxSwift

protocol FetchMyGroupNameListUseCase {
    func execute(token: Token) -> Single<[GroupName]>
    
}
