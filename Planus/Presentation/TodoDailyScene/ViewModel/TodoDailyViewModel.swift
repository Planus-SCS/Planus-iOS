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

    var isOwner: Bool?
    
    var scheduledTodoList: [Todo]?
    var unscheduledTodoList: [Todo]?

    var currentDate: Date?
    var currentDateText: String?
        
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    struct Input {
        var deleteTodoAt: Observable<IndexPath>
    }
    
    struct Output {
        var currentDateText: String?
        var isOwner: Bool?
        var needInsertItem: Observable<IndexPath>
        var needReloadItem: Observable<IndexPath>
        var needDeleteItem: Observable<IndexPath>
    }
    
    var needInsertItem = PublishSubject<IndexPath>()
    var needReloadItem = PublishSubject<IndexPath>()
    var needDeleteItem = PublishSubject<IndexPath>()
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    
    var createTodoUseCase: CreateTodoUseCase
    var updateTodoUseCase: UpdateTodoUseCase
    var deleteTodoUseCase: DeleteTodoUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createTodoUseCase: CreateTodoUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        deleteTodoUseCase: DeleteTodoUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.createTodoUseCase = createTodoUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
    }
    
    func setOwnership(isOwner: Bool) {
        self.isOwner = isOwner
    }
    
    func setDate(currentDate: Date) {
        self.currentDate = currentDate
        self.currentDateText = dateFormatter.string(from: currentDate)
    }
    
    func setTodoList(todoList: [Todo]) {
        var scheduled = [Todo]()
        var unscheduled = [Todo]()
        todoList.forEach {
            if let _ = $0.startTime {
                scheduled.append($0)
            } else {
                unscheduled.append($0)
            }
        }
        self.scheduledTodoList = scheduled
        self.unscheduledTodoList = unscheduled
        
        bindAfterSetTodoList()
    }
    
    func addTodo(todo: Todo) {
        guard let token = getTokenUseCase.execute() else { return }
        
        createTodoUseCase
            .execute(token: token, todo: todo)
            .subscribe(onSuccess: {
                print($0)
            })
            .disposed(by: bag)
    }
    
    func bindAfterSetTodoList() {
        createTodoUseCase
            .didCreateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                var section: Int
                var item: Int
                if let _ = todo.startTime {
                    vm.scheduledTodoList?.append(todo)
                    section = 0
                    item = (vm.scheduledTodoList?.count ?? Int()) - 1
                } else {
                    vm.unscheduledTodoList?.append(todo)
                    section = 1
                    item = (vm.unscheduledTodoList?.count ?? Int()) - 1
                }
                vm.needInsertItem.onNext(IndexPath(item: item, section: section))
            })
            .disposed(by: bag)
        
        updateTodoUseCase
            .didUpdateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                var section: Int
                var item: Int
                if let _ = todo.startTime {
                    section = 0
                    item = vm.scheduledTodoList?.firstIndex(where: { $0.id == todo.id }) ?? 0
                    vm.scheduledTodoList?[item] = todo
                } else {
                    section = 1
                    item = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todo.id }) ?? 0
                    vm.unscheduledTodoList?[item] = todo
                }
                vm.needReloadItem.onNext(IndexPath(item: item, section: section))
            })
            .disposed(by: bag)
        
        deleteTodoUseCase
            .didDeleteTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                var section: Int
                var item: Int
                if let _ = todo.startTime {
                    section = 0
                    item = vm.scheduledTodoList?.firstIndex(where: { $0.id == todo.id }) ?? 0
                    vm.scheduledTodoList?.remove(at: item)
                } else {
                    section = 1
                    item = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todo.id }) ?? 0
                    vm.unscheduledTodoList?.remove(at: item)
                }
                vm.needDeleteItem.onNext(IndexPath(item: item, section: section))
            })
            .disposed(by: bag)
    }
    
    func transform(input: Input) -> Output {
        
        return Output(
            currentDateText: currentDateText,
            isOwner: true,
            needInsertItem: needInsertItem.asObservable(),
            needReloadItem: needReloadItem.asObservable(),
            needDeleteItem: needDeleteItem.asObservable()
        )
    }

}
