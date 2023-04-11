//
//  TodoDailyViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import Foundation
import RxSwift

// 초기화할때 minDate, maxDate 정의 필요함, 왜? 스몰캘린더 때문에..!

class TodoDailyViewModel {
    var bag = DisposeBag()
    
    var minDate: Date?
    var maxDate: Date?
    
    var scheduledTodoList: [Todo]?
    var unscheduledTodoList: [Todo]?
    
    var didRequestTodoList = BehaviorSubject<Void?>(value: nil)
    var didFetchTodoList = BehaviorSubject<Void?>(value: nil)
    
    var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentDateText = BehaviorSubject<String?>(value: nil)
        
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    struct Input {
        var didChangedDate: Observable<Date>
    }
    
    struct Output {
        var didUpdateDateText: Observable<String?>
        var didRequestTodoList: Observable<Void?>
        var didFetchTodoList: Observable<Void?>
    }
    
    var fetchTodoListUseCase: ReadTodoListUseCase
    
    init(fetchTodoListUseCase: ReadTodoListUseCase) {
        self.fetchTodoListUseCase = fetchTodoListUseCase
        
        bind()
    }
    
    func setDate(currentDate: Date, min: Date, max: Date) {
        self.currentDate.onNext(currentDate)
        self.minDate = min
        self.maxDate = max
    }
    
    func bind() {
        currentDate
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vm, date in
                vm.updateDateText(date: date)
                vm.fetchTodoList(date: date)
            })
            .disposed(by: bag)
    }
    
    func transform(input: Input) -> Output {
        input
            .didChangedDate
            .withUnretained(self)
            .subscribe(onNext: { vm, date in
                vm.currentDate.onNext(date)
            })
            .disposed(by: bag)
        
        return Output(
            didUpdateDateText: currentDateText.asObservable(),
            didRequestTodoList: didRequestTodoList,
            didFetchTodoList: didFetchTodoList
        )
    }
    
    func updateDateText(date: Date) {
        currentDateText.onNext(dateFormatter.string(from: date))
    }
    
    func fetchTodoList(date: Date) {
        let nextDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: date) ?? date
        fetchTodoListUseCase.execute(from: date, to: nextDate)
            .subscribe(onSuccess: { [weak self] dict in
                var scheduled = [Todo]()
                var unscheduled = [Todo]()
                dict[date]?.forEach {
                    if let _ = $0.time {
                        scheduled.append($0)
                    } else {
                        unscheduled.append($0)
                    }
                }
                self?.scheduledTodoList = scheduled
                self?.unscheduledTodoList = unscheduled
                self?.didFetchTodoList.onNext(())
            }, onError: { error in
                print(error)
            })
            .disposed(by: bag)
        
    }
}
