//
//  MemberDailyCalendarViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation
import RxSwift

final class MemberDailyCalendarViewModel: DailyCalendarViewModelable {
    
    struct UseCases {
        var executeWithTokenUseCase: ExecuteWithTokenUseCase
        var fetchMemberDailyCalendarUseCase: FetchGroupMemberDailyCalendarUseCase
    }
    
    struct Actions {
        let showTodoDetail: ((MemberTodoDetailViewModel.Args) -> Void)?
        let finishScene: (() -> Void)?
    }
    
    struct Args {
        let group: GroupName
        let memberId: Int
        let date: Date
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    private let bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    private let group: GroupName
    private let memberId: Int
    private let currentDate: Date

    private var todos = [[SocialTodoDaily]](repeating: [SocialTodoDaily](), count: DailyCalendarTodoType.allCases.count)
    
    // MARK: - ViewModel
    var todoViewModels = [[TodoDailyViewModel]](repeating: [TodoDailyViewModel](), count: DailyCalendarTodoType.allCases.count)
    
    private var currentDateText: String?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    private let nowFetchLoading = BehaviorSubject<Void?>(value: nil)
    private let didFetchTodoList = BehaviorSubject<Void?>(value: nil)
    private let showAlert = PublishSubject<Message>()
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.group = injectable.args.group
        self.memberId = injectable.args.memberId
        self.currentDate = injectable.args.date
        
        self.currentDateText = dateFormatter.string(from: currentDate)
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMemberTodoList(memberId: vm.memberId)
            })
            .disposed(by: bag)
        
        input
            .todoSelectedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                let todoId: Int = vm.todoViewModels[indexPath.section][indexPath.item].todoId
                let args = MemberTodoDetailViewModel.Args(group: vm.group, memberId: vm.memberId, todoId: todoId)
                
                vm.actions.showTodoDetail?(args)
            })
            .disposed(by: bag)
        
        input
            .viewDidDismissed
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.finishScene?()
            })
            .disposed(by: bag)
        
        return Output(
            currentDateText: currentDateText,
            nowLoading: nowFetchLoading.asObservable(),
            needReloadData: didFetchTodoList.asObservable(),
            showAlert: showAlert.asObservable(),
            mode: .viewable
        )
    }
}

// MARK: - fetch
private extension MemberDailyCalendarViewModel {
    func fetchMemberTodoList(memberId: Int) {
        nowFetchLoading.onNext(())
        
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<[[SocialTodoDaily]]>? in
                guard let self else { return nil }
                return self.useCases.fetchMemberDailyCalendarUseCase
                    .execute(token: token, groupId: self.group.groupId, memberId: memberId, date: self.currentDate)
            }
            .subscribe(onSuccess: { [weak self] list in
                self?.todos = list
                self?.prepareViewModel(todos: list)
                self?.didFetchTodoList.onNext(())
            })
            .disposed(by: bag)
    }
}

// MARK: - prepare ViewModel
private extension MemberDailyCalendarViewModel {
    func prepareViewModel(todos: [[SocialTodoDaily]]) {
        self.todoViewModels = todos.map { list in
            return list.map { item in
                return item.toViewModel()
            }
        }
    }
}
