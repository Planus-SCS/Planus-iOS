//
//  CategorySelectViewModelable.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation
import RxSwift

struct CategorySelectViewModelInput {
    var categorySelectedAt: Observable<Int>
    var categoryEditRequiredWithId: Observable<Int>
    var categoryRemoveRequiredWithId: Observable<Int>
    var categoryCreateBtnTapped: Observable<Void>
    var backBtnTapped: Observable<Void>
    var needDismiss: Observable<Void>
}

struct CategorySelectViewModelOutput {
    var insertCategoryAt: Observable<Int>
    var reloadCategoryAt: Observable<Int>
    var removeCategoryAt: Observable<Int>
    var showMessage: Observable<Message>
}

protocol CategorySelectViewModelable: AnyObject, ViewModel {
    typealias Input = CategorySelectViewModelInput
    typealias Output = CategorySelectViewModelOutput
    
    var categories: [Category] { get set }    
}
