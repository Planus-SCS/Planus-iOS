//
//  JoinedGroupCalendarViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class JoinedGroupCalendarViewModel {
    
    var bag = DisposeBag()
    
    var groupId: Int?
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didChangedMonth: Observable<Date>
        var didSelectedAt: Observable<Int>
    }
    
    struct Output {
        var didFetchTodo: Observable<Void?>
        var showDaily: Observable<Date>
    }
    
    var today: Date = {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var currentDate: Date?
    var currentDateText: String?
    var mainDayList = [DayViewModel]()
    var todos = [Date: [SocialTodoSummary]]()
    
    var blockMemo = [[Int?]](repeating: [Int?](repeating: nil, count: 20), count: 42) //todoId
    var filteredTodoCache = [FilteredSocialTodoViewModel](repeating: FilteredSocialTodoViewModel(periodTodo: [], singleTodo: []), count: 42)
    var cachedCellHeightForTodoCount = [Int: Double]()
        
    var showDaily = PublishSubject<Date>()
    var didFetchTodo = BehaviorSubject<Void?>(value: nil)
    
    let getTokenUseCase: GetTokenUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let fetchMyGroupCalendarUseCase: FetchGroupMonthlyCalendarUseCase
    
    let createGroupTodoUseCase: CreateGroupTodoUseCase
    let updateGroupTodoUseCase: UpdateGroupTodoUseCase
    let deleteGroupTodoUseCase: DeleteGroupTodoUseCase
    let updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchMyGroupCalendarUseCase: FetchGroupMonthlyCalendarUseCase,
        createGroupTodoUseCase: CreateGroupTodoUseCase,
        updateGroupTodoUseCase: UpdateGroupTodoUseCase,
        deleteGroupTodoUseCase: DeleteGroupTodoUseCase,
        updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchMyGroupCalendarUseCase = fetchMyGroupCalendarUseCase
        
        self.createGroupTodoUseCase = createGroupTodoUseCase
        self.updateGroupTodoUseCase = updateGroupTodoUseCase
        self.deleteGroupTodoUseCase = deleteGroupTodoUseCase
        self.updateGroupCategoryUseCase = updateGroupCategoryUseCase
    }
    
    func setGroupId(id: Int) {
        self.groupId = id
    }
    
    func transform(input: Input) -> Output {
        
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                let components = Calendar.current.dateComponents(
                    [.year, .month],
                    from: Date()
                )
                
                let currentDate = Calendar.current.date(from: components) ?? Date()
                vm.createCalendar(date: currentDate)
            })
            .disposed(by: bag)
        
        input
            .didChangedMonth
            .withUnretained(self)
            .subscribe(onNext: { vm, date in
                vm.createCalendar(date: date)
            })
            .disposed(by: bag)
        
        input
            .didSelectedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                let date = vm.mainDayList[index].date
                vm.showDaily.onNext(date)
            })
            .disposed(by: bag)
        
        return Output(
            didFetchTodo: didFetchTodo.asObservable(),
            showDaily: showDaily.asObservable()
        )
    }
    
    func bindUseCase() {
        createGroupTodoUseCase //삽입하고 리로드 or 다시 받기.. 뭐가 좋을랑가 -> 걍 다시받자!
            .didCreateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.groupId == todo.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        updateGroupTodoUseCase // 삭제하고 다시넣기,,, 걍 다시받는게 편하겠지 아무래도?
            .didUpdateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.groupId == todo.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        deleteGroupTodoUseCase
            .didDeleteGroupTodoWithIds
            .withUnretained(self)
            .subscribe(onNext: { vm, ids in
                guard vm.groupId == ids.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        updateGroupCategoryUseCase
            .didUpdateCategoryWithGroupId
            .withUnretained(self)
            .subscribe(onNext: { vm, categoryWithGroupId in
                guard vm.groupId == categoryWithGroupId.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)

    }
    
    func createCalendar(date: Date) {
        updateCurrentDate(date: date)
        mainDayList = createMonthlyCalendarUseCase.execute(date: date)

        let startDate = mainDayList.first?.date ?? Date()
        let endDate = mainDayList.last?.date ?? Date()
        fetchTodo(from: startDate, to: endDate)
    }
    
    func updateCurrentDate(date: Date) {
        currentDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        self.currentDateText = dateFormatter.string(from: date)
    }
    
    func fetchTodo(from: Date, to: Date) {
        guard let groupId else { return }
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Date: [SocialTodoSummary]]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupCalendarUseCase
                    .execute(token: token, groupId: groupId, from: from, to: to)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return }
                self.todos = todoDict
                self.didFetchTodo.onNext(())
            })
            .disposed(by: bag)
        
    }
}
