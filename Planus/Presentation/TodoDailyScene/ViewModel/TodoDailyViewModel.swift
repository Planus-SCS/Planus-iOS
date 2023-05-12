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

    var isOwner: Bool?
    
    var scheduledTodoList: [Todo]?
    var unscheduledTodoList: [Todo]?
    
    var categoryDict: [Int: Category] = [:]
    var groupDict: [Int: Group] = [:]

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
        var needReloadData: Observable<Void>
    }
    
    var needInsertItem = PublishSubject<IndexPath>()
    var needReloadItem = PublishSubject<IndexPath>()
    var needDeleteItem = PublishSubject<IndexPath>()
    var needReloadData = PublishSubject<Void>()
    
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
    
    func setTodoList(todoList: [Todo], categoryDict: [Int: Category], groupDict: [Int: Group]) { // 여기서도 정렬해서 집어넣어야함..!
        self.categoryDict = categoryDict
        
        var scheduled = [Todo]()
        var unscheduled = [Todo]()
        todoList.forEach { todo in
            if let _ = todo.startTime {
                scheduled.append(todo)
            } else {
                unscheduled.append(todo)
            }
        }
        scheduled = scheduled.sorted { $0.startTime ?? String() < $1.startTime ?? String() }
        unscheduled = unscheduled.sorted { $0.id ?? Int() < $1.id ?? Int() }
        
        self.scheduledTodoList = scheduled
        self.unscheduledTodoList = unscheduled
        
    }
    
    func bindCategoryUseCase() {
        createCategoryUseCase
            .didCreateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                
                vm.categoryDict[id] = category
            })
            .disposed(by: bag)
        
        updateCategoryUseCase
            .didUpdateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                vm.categoryDict[id] = category
                vm.needReloadData.onNext(())
            })
            .disposed(by: bag)
        
//        deleteCategoryUseCase
//            .didDeleteCategory
//            .withUnretained(self)
//            .subscribe(onNext: { vm, id in
//
//            })
//            .disposed(by: bag)
    }
    
    // 내 투두 볼때만 불릴예정
    func bindTodoUseCase() {
        createTodoUseCase
            .didCreateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard todo.startDate == vm.currentDate else { return }
                var section: Int
                var item: Int
                if let _ = todo.startTime {
                    section = 0
                    item = vm.scheduledTodoList?.insertionIndexOf(todo, isOrderedBefore: { $0.startTime ?? String() < $1.startTime ?? String()}) ?? 0
                    vm.scheduledTodoList?.insert(todo, at: item)
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
            .subscribe(onNext: { vm, todoUpdate in
                let todoAfterUpdate = todoUpdate.after
                let todoBeforeUpdate = todoUpdate.before
                
                // MARK: 날짜가 바뀐 경우 -> 삭제
                if todoAfterUpdate.startDate != todoBeforeUpdate.startDate { //이전 todo로 인덱스를 찾아야함
                    var section: Int
                    var item: Int
                    
                    if let _ = todoBeforeUpdate.startTime {
                        section = 0
                        item = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id }) ?? 0
                        vm.scheduledTodoList?.remove(at: item)
                    } else {
                        section = 1
                        item = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id }) ?? 0
                        vm.unscheduledTodoList?.remove(at: item)
                    }
                    vm.needDeleteItem.onNext(IndexPath(item: item, section: section))
                } else {
                    switch (todoBeforeUpdate.startTime, todoAfterUpdate.startTime) {
                    case (nil, nil): //이건 그냥 그대로 바꿔주면됨!
                        let section = 1
                        let item = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todoAfterUpdate.id }) ?? 0
                        vm.unscheduledTodoList?[item] = todoAfterUpdate
                        vm.needReloadItem.onNext(IndexPath(item: item, section: section))
                    case (let _, nil):
                        let beforeSection = 0
                        let beforeItem = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id }) ?? 0
                        vm.scheduledTodoList?.remove(at: beforeItem)
                        vm.needDeleteItem.onNext(IndexPath(item: beforeItem, section: beforeSection))
                        
                        let afterSection = 1
                        let afterItem = vm.unscheduledTodoList?.insertionIndexOf(todoAfterUpdate) { $0.id ?? Int() < $1.id ?? Int() } ?? 0
                        vm.unscheduledTodoList?.insert(todoAfterUpdate, at: afterItem)
                        vm.needInsertItem.onNext(IndexPath(item: afterItem, section: afterSection))
                    case (nil, let afterTime):
                        let beforeSection = 1
                        let beforeItem = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id }) ?? 0
                        vm.unscheduledTodoList?.remove(at: beforeItem)
                        vm.needDeleteItem.onNext(IndexPath(item: beforeItem, section: beforeSection))
                        
                        let afterSection = 0
                        let afterItem = vm.scheduledTodoList?.insertionIndexOf(todoAfterUpdate) { $0.startTime ?? String() < $1.startTime ?? String() } ?? 0
                        vm.scheduledTodoList?.insert(todoAfterUpdate, at: afterItem)
                        vm.needInsertItem.onNext(IndexPath(item: afterItem, section: afterSection))
                    case (let beforeTime, let afterTime):
                        if beforeTime == afterTime { //시간이 바뀐게 아닐경우..!
                            let section = 0
                            let item = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoAfterUpdate.id }) ?? 0
                            vm.scheduledTodoList?[item] = todoAfterUpdate
                            vm.needReloadItem.onNext(IndexPath(item: item, section: section))
                        } else {
                            let section = 0
                            let beforeItem = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id }) ?? 0
                            vm.scheduledTodoList?.remove(at: beforeItem)
                            vm.needDeleteItem.onNext(IndexPath(item: beforeItem, section: section))
                            let afterItem = vm.scheduledTodoList?.insertionIndexOf(todoAfterUpdate) { $0.startTime ?? String() < $1.startTime ?? String() } ?? 0
                            vm.scheduledTodoList?.insert(todoAfterUpdate, at: afterItem)
                            vm.needInsertItem.onNext(IndexPath(item: afterItem, section: section))
                        }
                    }
                }
            
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
        bindTodoUseCase()
        bindCategoryUseCase()
        
        return Output(
            currentDateText: currentDateText,
            isOwner: true,
            needInsertItem: needInsertItem.asObservable(),
            needReloadItem: needReloadItem.asObservable(),
            needDeleteItem: needDeleteItem.asObservable(),
            needReloadData: needReloadData.asObservable()
        )
    }

}
