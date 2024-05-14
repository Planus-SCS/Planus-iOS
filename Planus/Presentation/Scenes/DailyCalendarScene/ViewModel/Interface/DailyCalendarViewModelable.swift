//
//  DailyCalendarViewModelable.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation
import RxSwift

enum DailyCalendarSceneAuthority {
    case editable //그룹장인 경우
    case viewable //그룹장 아닌 경우, 멤버 투두 (체크표시는 그냥 nil 아니면 보여주기)
    case interactable //내 투두
}

struct DailyCalendarViewModelableInput {
    var viewDidLoad: Observable<Void>
    var viewDidDismissed: Observable<Void>
    var addTodoTapped: Observable<Void>
    var todoSelectedAt: Observable<IndexPath>
    var deleteTodoAt: Observable<IndexPath>
    var completeTodoAt: Observable<IndexPath>
}

struct DailyCalendarViewModelableOutput {
    var currentDateText: String?
    
    var nowLoading: Observable<Void?>?
    var needInsertItem: Observable<IndexPath>?
    var needDeleteItem: Observable<IndexPath>?
    var needReloadData: Observable<Void?>?
    var needUpdateItem: Observable<(removed: IndexPath, created: IndexPath)>?
    
    var showAlert: Observable<Message>
    var mode: DailyCalendarSceneAuthority
}

protocol DailyCalendarViewModelable: ViewModelable {
    typealias Input = DailyCalendarViewModelableInput
    typealias Output = DailyCalendarViewModelableOutput
    
    var todoViewModels: [[TodoDailyViewModel]] { get set }
}


enum DailyCalendarTodoType: Int, CaseIterable {
    case scheduled = 0
    case unscheduled = 1
    
    var title: String {
        switch self {
        case .scheduled:
            "일정"
        case .unscheduled:
            "할일"
        }
    }
}
