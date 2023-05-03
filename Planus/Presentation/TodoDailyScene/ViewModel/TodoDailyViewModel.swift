//
//  TodoDailyViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import Foundation
import RxSwift

// 초기화할때 minDate, maxDate 정의 필요함, 왜? 스몰캘린더 때문에..!

// 애는 말그대로 보여주는 용도(진짜 그냥 창문느낌) 생각하자..! 카테고리를 굳이 또 로컬에서 가져와서 보여줄 필요는 없다! 그리고 남꺼 보는용으로 재활용하기 힘들다 그러면!
class TodoDailyViewModel {
    var bag = DisposeBag()

    var isOwner: Bool?
    
    var scheduledTodoList: [Todo]?
    var unscheduledTodoList: [Todo]?
    var categoryDict: [Int: Category] = [:]

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
    
    var createCategoryUseCase: CreateCategoryUseCase
    var updateCategoryUseCase: UpdateCategoryUseCase
    var deleteCategoryUseCase: DeleteCategoryUseCase
    var readCategoryUseCase: ReadCategoryListUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createTodoUseCase: CreateTodoUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        deleteTodoUseCase: DeleteTodoUseCase,
        createCategoryUseCase: CreateCategoryUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase,
        readCategoryUseCase: ReadCategoryListUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.createTodoUseCase = createTodoUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.readCategoryUseCase = readCategoryUseCase
    }
    
    func setOwnership(isOwner: Bool) {
        self.isOwner = isOwner
    }
    
    func setDate(currentDate: Date) {
        self.currentDate = currentDate
        self.currentDateText = dateFormatter.string(from: currentDate)
    }
    
    func setTodoList(todoList: [Todo], categoryDict: [Int: Category], groupDict: [Int: Group]) {
        var scheduled = [Todo]()
        var unscheduled = [Todo]()
        todoList.forEach { todo in
            if let _ = todo.startTime {
                scheduled.append(todo)
            } else {
                unscheduled.append(todo)
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
    
    // 내 투두 볼때만 불릴예정
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
