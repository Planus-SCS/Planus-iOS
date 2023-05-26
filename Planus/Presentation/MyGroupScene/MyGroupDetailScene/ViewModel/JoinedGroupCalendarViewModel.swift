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
    
    var currentDate: Date?
    var currentDateText: String?
    var mainDayList = [SocialDayViewModel]()
    var cachedCellHeightForTodoCount = [Int: Double]()
        
    var didFetchTodo = BehaviorSubject<Void?>(value: nil)
    
    let getTokenUseCase: GetTokenUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    let createSocialMonthlyCalendarUseCase: CreateSocialMonthlyCalendarUseCase
    let fetchMyGroupCalendarUseCase: FetchMyGroupCalendarUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createSocialMonthlyCalendarUseCase: CreateSocialMonthlyCalendarUseCase,
        fetchMyGroupCalendarUseCase: FetchMyGroupCalendarUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.createSocialMonthlyCalendarUseCase = createSocialMonthlyCalendarUseCase
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
            .subscribe(onNext: { index in
                print(index)
            })
            .disposed(by: bag)
        
        return Output(
            didFetchTodo: didFetchTodo
        )
    }
    
    func createCalendar(date: Date) {
        updateCurrentDate(date: date)
        mainDayList = createSocialMonthlyCalendarUseCase.execute(date: date)
        print(date)
        print(mainDayList)
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
    
    func getMaxInWeek(index: Int) -> SocialDayViewModel {
        let maxItem = ((index-index%7)..<(index+7-index%7)).max(by: { (a,b) in
            mainDayList[a].todoList.count < mainDayList[b].todoList.count
        }) ?? Int()

        return mainDayList[maxItem]
    }
    
    func fetchTodo(from: Date, to: Date) {
        guard let groupId else { return }
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[SocialTodoSummary]> in
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
            .subscribe(onSuccess: { [weak self] list in
                guard let self else { return }
                
                var todoDict = [Date: [SocialTodoSummary]]()
                list.forEach { todo in
                    if todoDict[todo.startDate] == nil {
                        todoDict[todo.startDate] = []
                    }
                    todoDict[todo.startDate]?.append(todo)
                }
                
                self.mainDayList = self.mainDayList.map {
                    guard let todoList = todoDict[$0.date] else {
                        return $0
                    }
                    var dayViewModel = $0
                    dayViewModel.todoList = todoList
                    return dayViewModel
                }
                self.didFetchTodo.onNext(())
            })
            .disposed(by: bag)
        
    }
}
