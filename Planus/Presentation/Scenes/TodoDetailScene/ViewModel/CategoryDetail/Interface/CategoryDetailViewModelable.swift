//
//  CategoryDetailViewModelable.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation
import RxSwift

struct CategoryDetailViewModelInput {
    var categoryColorSelected: Observable<CategoryColor?>
    var categoryTitleChanged: Observable<String?>
    var saveBtnTapped: Observable<Void>
    var backBtnTapped: Observable<Void>
    var needDismiss: Observable<Void>
}

struct CategoryDetailViewModelOutput {
    var categoryTitleValue: String?
    var categoryColorIndexValue: Int?
    var saveBtnEnabled: Observable<Bool>
    var showMessage: Observable<Message>
}

protocol CategoryDetailViewModelable: AnyObject, ViewModelable {
    typealias Input = CategoryDetailViewModelInput
    typealias Output = CategoryDetailViewModelOutput
    
    var categoryColorList: [CategoryColor] { get }    
}
