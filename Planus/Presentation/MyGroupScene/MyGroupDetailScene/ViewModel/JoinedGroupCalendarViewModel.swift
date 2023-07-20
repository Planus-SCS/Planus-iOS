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
    let fetchMyGroupCalendarUseCase: FetchMyGroupCalendarUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchMyGroupCalendarUseCase: FetchMyGroupCalendarUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchMyGroupCalendarUseCase = fetchMyGroupCalendarUseCase
    }
    
    func setGroupId(id: Int) {
        self.groupId = id
    }
    
    func transform(input: Input) -> Output {
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
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return }
                self.todos = todoDict
                print(self.mainDayList.count)
                self.didFetchTodo.onNext(())
            })
            .disposed(by: bag)
        
    }
}
