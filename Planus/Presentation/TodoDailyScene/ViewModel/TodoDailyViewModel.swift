//
//  TodoDailyViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import Foundation
import RxSwift

class TodoDailyViewModel {
    var bag = DisposeBag()
    
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
        var didRequestTodoList: Observable<Void?>
        var didFetchTodoList: Observable<Void?>
    }
    
    var fetchTodoListUseCase: FetchTodoListUseCase
    
    init(fetchTodoListUseCase: FetchTodoListUseCase) {
        self.fetchTodoListUseCase = fetchTodoListUseCase
        
        bind()
    }
    
    func setDate(date: Date) {
        currentDate.onNext(date)
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
            didRequestTodoList: didRequestTodoList,
            didFetchTodoList: didFetchTodoList
        )
    }
    
    func updateDateText(date: Date) {
        currentDateText.onNext(dateFormatter.string(from: date))
    }
    
    func fetchTodoList(date: Date) {
        fetchTodoListUseCase.execute(from: date, to: date)
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
