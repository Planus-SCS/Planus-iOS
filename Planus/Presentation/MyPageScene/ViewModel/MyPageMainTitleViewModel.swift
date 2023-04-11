//
//  MyPageMainTitleViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import Foundation
import RxSwift

enum MyPageMainListType {
    case normal
    case toggle(BehaviorSubject<Bool>)
}

struct MyPageMainTitleViewModel {
    var title: String
    var type: MyPageMainListType
}
