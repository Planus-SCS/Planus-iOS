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
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didChangedMonth: Observable<Date>
        var didSelectedAt: Observable<Int>
    }
    
    struct Output {
        var didCreateCalendar: Observable<Void?>
        var didFetchTodo: Observable<Void?>
    }
    
    var mainDayList = [DayViewModel]()
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    var date = Date()
    
    var didCreateCalendar = BehaviorSubject<Void?>(value: nil)
    var didFetchTodo = BehaviorSubject<Void?>(value: nil)
    
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let fetchTodoListUseCase: ReadTodoListUseCase
    
    
    init(
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchTodoListUseCase: ReadTodoListUseCase
    ) {
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchTodoListUseCase = fetchTodoListUseCase
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.createCalendar(date: vm.date)
                vm.fetchTodo()
            })
            .disposed(by: bag)
        
        input
            .didSelectedAt
            .subscribe(onNext: { index in
                print(index)
            })
            .disposed(by: bag)
        
        return Output(
            didCreateCalendar: didCreateCalendar,
            didFetchTodo: didFetchTodo
        )
    }
    
    func createCalendar(date: Date) {
        mainDayList = createMonthlyCalendarUseCase.execute(date: date)
    }
    
    func fetchTodo() {
        // 패치하는 메서드 추후 추가하기
    }
}
