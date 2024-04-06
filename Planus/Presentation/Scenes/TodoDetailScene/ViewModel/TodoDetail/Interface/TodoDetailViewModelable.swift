//
//  TodoDetailViewModelable.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

enum SceneAuthority {
    case new
    case editable
    case viewable
    case interactable
}

struct TodoDetailViewModelableInput {
    // MARK: Control Value
    var titleTextChanged: Observable<String?>
    var dayRange: Observable<DateRange>
    var timeFieldChanged: Observable<String?>
    var groupSelectedAt: Observable<Int?>
    var memoTextChanged: Observable<String?>
    
    // MARK: Control Event
    var categoryBtnTapped: Observable<Void>
    var todoSaveBtnTapped: Observable<Void>
    var todoRemoveBtnTapped: Observable<Void>
    var needDismiss: Observable<Void>
}

struct TodoDetailViewModelableOutput {
    var mode: SceneAuthority
    var titleValueChanged: Observable<String?>
    var categoryChanged: Observable<Category?>
    var dayRangeChanged: Observable<DateRange>
    var timeValueChanged: Observable<String?>
    var groupChangedToIndex: Observable<Int?>
    var memoValueChanged: Observable<String?>
    var showMessage: Observable<Message>
    var showSaveConstMessagePopUp: Observable<Void>
    var dismissRequired: Observable<Void>
}

protocol TodoDetailViewModelable: AnyObject, ViewModel {
    typealias Input = TodoDetailViewModelableInput
    typealias Output = TodoDetailViewModelableOutput
    
    var groups: [GroupName] { get set }    
}
