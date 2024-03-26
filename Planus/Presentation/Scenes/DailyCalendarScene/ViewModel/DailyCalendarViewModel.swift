//
//  DailyCalendarViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import Foundation
import RxSwift
import RxCocoa

final class DailyCalendarViewModel: ViewModel {
    
    struct UseCases {
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        
        let createTodoUseCase: CreateTodoUseCase
        let updateTodoUseCase: UpdateTodoUseCase
        let deleteTodoUseCase: DeleteTodoUseCase
        
        let todoCompleteUseCase: TodoCompleteUseCase
        
        let createCategoryUseCase: CreateCategoryUseCase
        let updateCategoryUseCase: UpdateCategoryUseCase
        let deleteCategoryUseCase: DeleteCategoryUseCase
        let readCategoryUseCase: ReadCategoryListUseCase
    }
    
    struct Actions {
        var showTodoDetailPage: ((MemberTodoDetailViewModel.Args, (() -> Void)?) -> Void)?
        var finishScene: (() -> Void)?
    }
    
    struct Args {
        let currentDate: Date
        let todoList: [Todo]
        let categoryDict: [Int: Category]
        let groupDict: [Int: GroupName]
        let groupCategoryDict: [Int: Category]
        let filteringGroupId: Int?
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    let bag = DisposeBag()
    let useCases: UseCases
    let actions: Actions
    
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
        var addTodoTapped: Observable<Void>
        var todoSelectedAt: Observable<IndexPath>
        var deleteTodoAt: Observable<IndexPath>
        var completeTodoAt: Observable<IndexPath>
    }
    
    struct Output {
        var currentDateText: String?
        var needInsertItem: Observable<IndexPath>
        var needReloadItem: Observable<IndexPath>
        var needDeleteItem: Observable<IndexPath>
        var needReloadData: Observable<Void>
        var needMoveItem: Observable<(IndexPath, IndexPath)>
    }
    
    var needInsertItem = PublishSubject<IndexPath>()
    var needReloadItem = PublishSubject<IndexPath>()
    var needDeleteItem = PublishSubject<IndexPath>()
    var needReloadData = PublishSubject<Void>()
    var needMoveItem = PublishSubject<(IndexPath, IndexPath)>()
    

    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        setDate(currentDate: injectable.args.currentDate)
        setCategoryAndGroup(
            categoryDict: injectable.args.categoryDict,
            groupDict: injectable.args.groupDict,
            groupCategoryDict: injectable.args.groupCategoryDict,
            filteringGroupId: injectable.args.filteringGroupId
        )
        setTodoListSorted(todoList: injectable.args.todoList)
    }
    
    func transform(input: Input) -> Output {
        bindTodoUseCase()
        bindCategoryUseCase()
        
        input
            .addTodoTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                let groupList = Array(vm.groupDict.values).sorted(by: { $0.groupId < $1.groupId })
                
                var groupName: GroupName?
                if let filteredGroupId = vm.filteringGroupId,
                   let filteredGroupName = vm.groupDict[filteredGroupId] {
                    groupName = filteredGroupName
                }
                
                vm.actions.showTodoDetailPage?(
                    MemberTodoDetailViewModel.Args(
                        groupList: groupList,
                        mode: .new,
                        todo: nil,
                        category: nil,
                        groupName: groupName,
                        start: vm.currentDate,
                        end: nil
                    ), nil
                )
            })
            .disposed(by: bag)
        
        input
            .todoSelectedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                vm.todoItemSelected(at: indexPath)
            })
            .disposed(by: bag)
        
        input
            .completeTodoAt
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                vm.completeTodoDataAt(indexPath: indexPath)
            })
            .disposed(by: bag)
        
        return Output(
            currentDateText: currentDateText,
            needInsertItem: needInsertItem.asObservable(),
            needReloadItem: needReloadItem.asObservable(),
            needDeleteItem: needDeleteItem.asObservable(),
            needReloadData: needReloadData.asObservable(),
            needMoveItem: needMoveItem.asObservable()
        )
    }
}

// MARK: bind useCase
private extension DailyCalendarViewModel {
    func bindTodoUseCase() {
        useCases.createTodoUseCase
            .didCreateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.notifiedTodoCreated(todo: todo)
            })
            .disposed(by: bag)
        
        useCases.updateTodoUseCase
            .didUpdateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todoUpdate in
                vm.notifiedTodoUpdated(before: todoUpdate.before, after: todoUpdate.after)
            })
            .disposed(by: bag)
        
        useCases.deleteTodoUseCase
            .didDeleteTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.notifiedTodoRemoved(todo: todo)
            })
            .disposed(by: bag)
    }
    
    func bindCategoryUseCase() {
        useCases.createCategoryUseCase
            .didCreateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                
                vm.categoryDict[id] = category
            })
            .disposed(by: bag)
        
        useCases.updateCategoryUseCase
            .didUpdateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                vm.categoryDict[id] = category
                vm.needReloadData.onNext(())
            })
            .disposed(by: bag)
        
    }
}

// MARK: - set
private extension DailyCalendarViewModel {
    func setDate(currentDate: Date) {
        self.currentDate = currentDate
        self.currentDateText = dateFormatter.string(from: currentDate)
    }
    
    func setCategoryAndGroup(
        categoryDict: [Int: Category],
        groupDict: [Int: GroupName],
        groupCategoryDict: [Int: Category],
        filteringGroupId: Int?
    ) {
        self.categoryDict = categoryDict
        self.groupCategoryDict = groupCategoryDict
        self.groupDict = groupDict
        self.filteringGroupId = filteringGroupId
    }
    
    private func setTodoListSorted(todoList: [Todo]) {
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
    }
}

// MARK: Todo Actions
private extension DailyCalendarViewModel {
    func notifiedTodoCreated(todo: Todo) {
        guard let currentDate,
              todo.startDate <= currentDate,
              currentDate <= todo.endDate else { return }
        
        if let filteringGroupId = filteringGroupId,
           todo.groupId != filteringGroupId {
            return
        }
        
        createTodoData(todo: todo)
    }
    
    func notifiedTodoRemoved(todo: Todo) {
        removeTodoData(todo: todo)
    }
    
    func notifiedTodoUpdated(before: Todo, after: Todo) {
        guard let currentDate else { return }
        
        if after.startDate > currentDate || after.endDate < currentDate { //날짜 변경 시 제거
            removeTodoData(todo: before)
        }
        else if let filteringGroupId = filteringGroupId,
                after.groupId != filteringGroupId { //만약 필터링 중인데 그룹이 바뀐 경우 제거
            removeTodoData(todo: before)
        }
        else {
            updateTodoData(todoBeforeUpdate: before, todoAfterUpdate: after)
        }
    }
    
    func createTodoData(todo: Todo) {
        var section: Int
        var item: Int
        if let _ = todo.startTime {
            section = 0
            let memberTodoList = scheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
            let innerIndex = memberTodoList?.insertionIndexOf(
                (Int(), todo),
                isOrderedBefore: { $0.1.startTime ?? String() < $1.1.startTime ?? String() }
             ) ?? 0
            
            item = innerIndex == memberTodoList?.count ? scheduledTodoList?.count ?? 0 : memberTodoList?[innerIndex].0 ?? 0
            scheduledTodoList?.insert(todo, at: item)
        } else {
            unscheduledTodoList?.append(todo)
            section = 1
            item = (unscheduledTodoList?.count ?? Int()) - 1
        }
        needInsertItem.onNext(IndexPath(item: item, section: section))
    }
    
    func removeTodoData(todo: Todo) {
        var section: Int
        var item: Int
        
        if let _ = todo.startTime {
            section = 0
            item = scheduledTodoList?.firstIndex(where: { $0.id == todo.id && !$0.isGroupTodo }) ?? 0
            scheduledTodoList?.remove(at: item)
        } else {
            section = 1
            item = unscheduledTodoList?.firstIndex(where: { $0.id == todo.id && !$0.isGroupTodo }) ?? 0
            unscheduledTodoList?.remove(at: item)
        }
        needDeleteItem.onNext(IndexPath(item: item, section: section))
    }
    
    func updateTodoData(todoBeforeUpdate: Todo, todoAfterUpdate: Todo) {
        switch (todoBeforeUpdate.startTime, todoAfterUpdate.startTime) {
        case (nil, nil): //시간 업데이트 x
            let section = 1
            let item = unscheduledTodoList?.firstIndex(where: { $0.id == todoAfterUpdate.id && !$0.isGroupTodo }) ?? 0
            unscheduledTodoList?[item] = todoAfterUpdate
            needReloadItem.onNext(IndexPath(item: item, section: section))
        case (_, nil): //시간 제거
            let beforeSection = 0
            let beforeItem = scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
            scheduledTodoList?.remove(at: beforeItem)
            
            let afterSection = 1
            
            let memberTodoList = unscheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
            
            let innerIndex = memberTodoList?.insertionIndexOf(
                (Int(), todoAfterUpdate),
                isOrderedBefore: { $0.1.id ?? Int() < $1.1.id ?? Int() }
             ) ?? 0
            
            let afterItem = (innerIndex == memberTodoList?.count ? unscheduledTodoList?.count ?? 0 : memberTodoList?[innerIndex].0) ?? 0

            unscheduledTodoList?.insert(todoAfterUpdate, at: afterItem)
            needMoveItem.onNext((IndexPath(item: beforeItem, section: beforeSection), IndexPath(item: afterItem, section: afterSection)))
        case (nil, _): //시간이 생김
            let beforeSection = 1
            let beforeItem = unscheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
            unscheduledTodoList?.remove(at: beforeItem)
            
            let afterSection = 0
            
            let memberTodoList = scheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
            let innerIndex = memberTodoList?.insertionIndexOf(
                (Int(), todoAfterUpdate),
                isOrderedBefore: { $0.1.startTime ?? String() < $1.1.startTime ?? String() }
             ) ?? 0
            
            let afterItem = (innerIndex == memberTodoList?.count ? scheduledTodoList?.count : memberTodoList?[innerIndex].0) ?? 0

            scheduledTodoList?.insert(todoAfterUpdate, at: afterItem)
            needMoveItem.onNext((IndexPath(item: beforeItem, section: beforeSection), IndexPath(item: afterItem, section: afterSection)))
        case (let beforeTime, let afterTime):
            if beforeTime == afterTime { //시간이 변경 x
                let section = 0
                let item = scheduledTodoList?.firstIndex(where: { $0.id == todoAfterUpdate.id && !$0.isGroupTodo }) ?? 0
                scheduledTodoList?[item] = todoAfterUpdate
                needReloadItem.onNext(IndexPath(item: item, section: section))
            } else { //시간 변경
                let section = 0
                let beforeItem = scheduledTodoList?.firstIndex(where: { $0.id == todoBeforeUpdate.id && !$0.isGroupTodo }) ?? 0
                scheduledTodoList?.remove(at: beforeItem)
                
                let memberTodoList = scheduledTodoList?.enumerated().filter { !$1.isGroupTodo }
                
                let innerIndex = memberTodoList?.insertionIndexOf(
                    (Int(), todoAfterUpdate),
                    isOrderedBefore: { $0.1.startTime ?? String() < $1.1.startTime ?? String() }
                 ) ?? 0
                
                let afterItem = (innerIndex == memberTodoList?.count ? scheduledTodoList?.count : memberTodoList?[innerIndex].0) ?? 0
                
                scheduledTodoList?.insert(todoAfterUpdate, at: afterItem)
                needMoveItem.onNext((IndexPath(item: beforeItem, section: section), IndexPath(item: afterItem, section: section)))
            }
        }
    }
    
    func completeTodoDataAt(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard var todo = scheduledTodoList?[indexPath.item],
                  var isCompleted = todo.isCompleted else { return }
            isCompleted = !isCompleted
            todo.isCompleted = isCompleted
            scheduledTodoList?[indexPath.item] = todo
            sendCompletionState(todo: todo)
        case 1:
            guard var todo = unscheduledTodoList?[indexPath.item],
                  var isCompleted = todo.isCompleted else { return }
            isCompleted = !isCompleted
            todo.isCompleted = isCompleted
            unscheduledTodoList?[indexPath.item] = todo
            sendCompletionState(todo: todo)
        default:
            return
        }
    }
}

private extension DailyCalendarViewModel {
    func todoItemSelected(at indexPath: IndexPath) {
        var item: Todo?
        switch indexPath.section {
        case 0:
            if let scheduledList = scheduledTodoList,
               !scheduledList.isEmpty {
                item = scheduledList[indexPath.item]
            } else {
                return
            }
        case 1:
            if let unscheduledList = unscheduledTodoList,
               !unscheduledList.isEmpty {
                item = unscheduledList[indexPath.item]
            } else {
                return
            }
        default:
            return
        }
        guard let item else { return  }

        let groupList = Array(groupDict.values).sorted(by: { $0.groupId < $1.groupId })
        var groupName: GroupName?
        var mode: TodoDetailSceneMode
        var category: Category?
        
        if item.isGroupTodo {
            guard let groupId = item.groupId else { return }
            groupName = groupDict[groupId]
            mode = .view
            category = groupCategoryDict[item.categoryId]
        } else {
            if let groupId = item.groupId {
                groupName = groupDict[groupId]
            }
            mode = .edit
            category = categoryDict[item.categoryId]
        }

        actions.showTodoDetailPage?(
            MemberTodoDetailViewModel.Args(
                groupList: groupList,
                mode: mode,
                todo: item,
                category: category,
                groupName: groupName,
                start: currentDate,
                end: nil
            ), nil
        )
    }
}

// MARK: API
private extension DailyCalendarViewModel {
    func sendCompletionState(todo: Todo) {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.todoCompleteUseCase
                    .execute(token: token, todo: todo)
            }
            .subscribe(onFailure: { _ in })
            .disposed(by: bag)
    }
}
