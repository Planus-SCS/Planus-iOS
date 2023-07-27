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
    
    var categoryDict: [Int: Category] = [:]
    var groupCategoryDict: [Int: Category] = [:]
    var groupDict: [Int: GroupName] = [:]
    
    var filteringGroupId: Int?

    var currentDate: Date?
    var currentDateText: String?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    struct Input {
        var deleteTodoAt: Observable<IndexPath>
        var completeTodoAt: Observable<IndexPath>
    }
    
    struct Output {
        var currentDateText: String?
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
    
    var todoCompleteUseCase: TodoCompleteUseCase
    
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
        todoCompleteUseCase: TodoCompleteUseCase,
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
        self.todoCompleteUseCase = todoCompleteUseCase
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.readCategoryUseCase = readCategoryUseCase
    }
    
    func setDate(currentDate: Date) {
        self.currentDate = currentDate
        self.currentDateText = dateFormatter.string(from: currentDate)
    }
    
    func setTodoList(
        todoList: [Todo],
        categoryDict: [Int: Category],
        groupDict: [Int: GroupName],
        groupCategoryDict: [Int: Category],
        filteringGroupId: Int?
    ) {
        self.categoryDict = categoryDict
        self.groupCategoryDict = groupCategoryDict
        self.groupDict = groupDict
        
        var scheduled = [Todo]()
        var unscheduled = [Todo]()
        todoList.forEach { todo in
            if let _ = todo.startTime {
                scheduled.append(todo)
            } else {
                unscheduled.append(todo)
            }
        }
        if let filteringGroupId {
            scheduled = scheduled.filter { $0.groupId == filteringGroupId }
            unscheduled = unscheduled.filter { $0.groupId == filteringGroupId }
        }
        
        let idComparator: ((Todo, Todo) -> Bool) = { $0.id ?? Int() < $1.id ?? Int() }
        let timeComparator: ((Todo, Todo) -> Bool) = { $0.startTime ?? String() < $1.startTime ?? String() }
        scheduled
        = scheduled.filter { $0.isGroupTodo }.sorted(by: timeComparator)
        + scheduled.filter { !$0.isGroupTodo }.sorted(by: timeComparator)
        
        unscheduled
        = unscheduled.filter { $0.isGroupTodo }.sorted(by: idComparator)
        + unscheduled.filter { !$0.isGroupTodo }.sorted(by: idComparator)
        
        self.scheduledTodoList = scheduled
        self.unscheduledTodoList = unscheduled
        
        self.filteringGroupId = filteringGroupId
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

    }
    
    // 내 투두 볼때만 불릴예정
    func bindTodoUseCase() {
        createTodoUseCase
            .didCreateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in //무조건 추가하면 안된다.. 그룹보고 필터그룹이랑 다르면 추가 x
                guard let currentDate = vm.currentDate,
                      todo.startDate <= currentDate,
                      currentDate <= todo.endDate else { return }
                
                if let filteringGroupId = vm.filteringGroupId,
                   todo.groupId != filteringGroupId {
                    return
                }
                
                var section: Int
                var item: Int
                if let _ = todo.startTime {
                    section = 0
                    let memberTodoList = vm.scheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
                    let innerIndex = memberTodoList?.insertionIndexOf(
                        (Int(), todo),
                        isOrderedBefore: { $0.1.startTime ?? String() < $1.1.startTime ?? String() }//////////////
                     ) ?? 0
                    
                    item = innerIndex == memberTodoList?.count ? vm.scheduledTodoList?.count ?? 0 : memberTodoList?[innerIndex].0 ?? 0
                    
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
            .subscribe(onNext: { vm, todoUpdate in //무조건 그대로 두면 안된다,,, 그룹을 확인해서 빼줘야한다..!
                let todoAfterUpdate = todoUpdate.after
                let todoBeforeUpdate = todoUpdate.before
                
                // MARK: 날짜가 포함 안되는 경우 걍 삭제해버림!
                guard let currentDate = vm.currentDate else { return }
                
                if todoAfterUpdate.startDate > currentDate || todoAfterUpdate.endDate < currentDate {
                    var section: Int
                    var item: Int
                    
                    if let _ = todoBeforeUpdate.startTime {
                        section = 0
                        item = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                        vm.scheduledTodoList?.remove(at: item)
                    } else {
                        section = 1
                        item = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                        vm.unscheduledTodoList?.remove(at: item)
                    }
                    vm.needDeleteItem.onNext(IndexPath(item: item, section: section))
                }
                else if let filteringGroupId = vm.filteringGroupId,
                        todoAfterUpdate.groupId != filteringGroupId { //만약 필터링중에 그룹을 바꾼경우..! -> 삭제
                    var section: Int
                    var item: Int
                    
                    if let _ = todoBeforeUpdate.startTime {
                        section = 0
                        item = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                        vm.scheduledTodoList?.remove(at: item)
                    } else {
                        section = 1
                        item = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                        vm.unscheduledTodoList?.remove(at: item)
                    }
                    vm.needDeleteItem.onNext(IndexPath(item: item, section: section))
                }
                else {
                    switch (todoBeforeUpdate.startTime, todoAfterUpdate.startTime) {
                    case (nil, nil): //이건 그냥 그대로 바꿔주면됨!
                        let section = 1
                        let item = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todoAfterUpdate.id && !$0.isGroupTodo }) ?? 0
                        vm.unscheduledTodoList?[item] = todoAfterUpdate
                        vm.needReloadItem.onNext(IndexPath(item: item, section: section))
                    case (_, nil): //일정에서 투두로
                        let beforeSection = 0
                        let beforeItem = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                        vm.scheduledTodoList?.remove(at: beforeItem)
                        vm.needDeleteItem.onNext(IndexPath(item: beforeItem, section: beforeSection))
                        
                        let afterSection = 1
                        
                        let memberTodoList = vm.unscheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
                        
                        let innerIndex = memberTodoList?.insertionIndexOf(
                            (Int(), todoAfterUpdate),
                            isOrderedBefore: { $0.1.id ?? Int() < $1.1.id ?? Int() }//////////////
                         ) ?? 0
                        
                        let afterItem = innerIndex == memberTodoList?.count ? vm.unscheduledTodoList?.count ?? 0 : memberTodoList?[innerIndex].0 ?? 0

                        vm.needInsertItem.onNext(IndexPath(item: afterItem, section: afterSection))
                    case (nil, _): //투두에서 일정으로
                        let beforeSection = 1
                        let beforeItem = vm.unscheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                        vm.unscheduledTodoList?.remove(at: beforeItem)
                        vm.needDeleteItem.onNext(IndexPath(item: beforeItem, section: beforeSection))
                        
                        let afterSection = 0
                        
                        let memberTodoList = vm.scheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
                        // 끝에놈에 추가될때는 어케해야하지..? -> 끝에놈은 인덱싱이 안되므로 끝에 달한 경우에 따로 처리 못하나..?
                        let innerIndex = memberTodoList?.insertionIndexOf(
                            (Int(), todoAfterUpdate),
                            isOrderedBefore: { $0.1.startTime ?? String() < $1.1.startTime ?? String() }//////////////
                         ) ?? 0
                        
                        let afterItem = innerIndex == memberTodoList?.count ? vm.scheduledTodoList?.count : memberTodoList?[innerIndex].0 ?? 0

                        vm.scheduledTodoList?.insert(todoAfterUpdate, at: afterItem ?? 0)
                        vm.needInsertItem.onNext(IndexPath(item: afterItem ?? 0, section: afterSection))
                    case (let beforeTime, let afterTime):
                        if beforeTime == afterTime { //시간이 바뀐게 아닐경우..!
                            let section = 0
                            let item = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoAfterUpdate.id && !$0.isGroupTodo }) ?? 0
                            vm.scheduledTodoList?[item] = todoAfterUpdate
                            vm.needReloadItem.onNext(IndexPath(item: item, section: section))
                        } else {
                            let section = 0
                            let beforeItem = vm.scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                            vm.scheduledTodoList?.remove(at: beforeItem)
                            vm.needDeleteItem.onNext(IndexPath(item: beforeItem, section: section))
                            
                            let memberTodoList = vm.scheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
                            
                            let innerIndex = memberTodoList?.insertionIndexOf(
                                (Int(), todoAfterUpdate),
                                isOrderedBefore: { $0.1.startTime ?? String() < $1.1.startTime ?? String() }//////////////
                             ) ?? 0
                            
                            let afterItem = innerIndex == memberTodoList?.count ? vm.scheduledTodoList?.count ?? 0 : memberTodoList?[innerIndex].0 ?? 0

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
        
        input
            .completeTodoAt
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                switch indexPath.section {
                case 0:
                    guard var todo = vm.scheduledTodoList?[indexPath.item],
                          var isCompleted = todo.isCompleted else { return }
                    isCompleted = !isCompleted
                    todo.isCompleted = isCompleted
                    vm.scheduledTodoList?[indexPath.item] = todo
                    vm.updateCompletionState(todo: todo)
                case 1:
                    guard var todo = vm.unscheduledTodoList?[indexPath.item],
                          var isCompleted = todo.isCompleted else { return }
                    isCompleted = !isCompleted
                    todo.isCompleted = isCompleted
                    vm.unscheduledTodoList?[indexPath.item] = todo
                    vm.updateCompletionState(todo: todo)
                default:
                    return
                }
            })
            .disposed(by: bag)
        
        return Output(
            currentDateText: currentDateText,
            needInsertItem: needInsertItem.asObservable(),
            needReloadItem: needReloadItem.asObservable(),
            needDeleteItem: needDeleteItem.asObservable(),
            needReloadData: needReloadData.asObservable()
        )
    }
    
    func updateCompletionState(todo: Todo) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.todoCompleteUseCase
                    .execute(token: token, todo: todo)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onFailure: { _ in
                // 처리 실패하면 버튼을 다시 원래대로 돌리면서 토스트 띄워야함..!
                
            })
            .disposed(by: bag)
    }

}
