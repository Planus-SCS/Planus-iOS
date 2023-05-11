//
//  TodoDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation
import RxSwift

enum CategoryCreateState {
    case new
    case edit(Int)
}

enum TodoCreateState {
    case new
    case edit(Todo)
}

final class TodoDetailViewModel {
    var bag = DisposeBag()
    
    var completionHandler: ((Todo) -> Void)?
    
    var categoryColorList: [CategoryColor] = Array(CategoryColor.allCases[0..<CategoryColor.allCases.count-1])
    
    var categorys: [Category] = []
    var groups: [Group] = []
    
    var todoCreateState: TodoCreateState = .new
    var categoryCreatingState: CategoryCreateState = .new
    
    var todoTitle = BehaviorSubject<String?>(value: nil)
    var todoCategory = BehaviorSubject<Category?>(value: nil)
    var todoStartDay = BehaviorSubject<Date?>(value: nil)
    var todoEndDay: Date?
    var todoTime = BehaviorSubject<String?>(value: nil)
    var todoGroup = BehaviorSubject<Group?>(value: nil)
    var todoMemo = BehaviorSubject<String?>(value: nil)
    
    var needDismiss = PublishSubject<Void>()
    
    var newCategoryName = BehaviorSubject<String?>(value: nil)
    var newCategoryColor = BehaviorSubject<CategoryColor?>(value: nil)
    
    var groupListChanged = PublishSubject<Void>()
    
    let moveFromAddToSelect = PublishSubject<Void>()
    let moveFromSelectToCreate = PublishSubject<Void>()
    let moveFromCreateToSelect = PublishSubject<Void>()
    let moveFromSelectToAdd = PublishSubject<Void>()
    let needReloadCategoryList = PublishSubject<Void>()
    let removeKeyboard = PublishSubject<Void>()
    
    struct Input {
        // MARK: Control Value
        var todoTitleChanged: Observable<String?>
        var categorySelected: Observable<Int?>
        var startDayChanged: Observable<Date?>
        var endDayChanged: Observable<Date?>
        var timeChanged: Observable<String?>
        var groupSelected: Observable<Int?>
        var memoChanged: Observable<String?>
        var newCategoryNameChanged: Observable<String?>
        var newCategoryColorChanged: Observable<CategoryColor?>
        var didRemoveCategory: Observable<Int>
        
        // MARK: Control Event
        var categoryEditRequested: Observable<Int>
        var startDayButtonTapped: Observable<Void>
        var endDayButtonTapped: Observable<Void>
        var categorySelectBtnTapped: Observable<Void>
        var todoSaveBtnTapped: Observable<Void>
        var todoRemoveBtnTapped: Observable<Void>
        var newCategoryAddBtnTapped: Observable<Void>
        var newCategorySaveBtnTapped: Observable<Void>
        var categorySelectPageBackBtnTapped: Observable<Void>
        var categoryCreatePageBackBtnTapped: Observable<Void>
    }
    
    struct Output {
        var categoryChanged: Observable<Category?>
        var todoSaveBtnEnabled: Observable<Bool>
        var newCategorySaveBtnEnabled: Observable<Bool>
        var newCategorySaved: Observable<Void>
        var moveFromAddToSelect: Observable<Void>
        var moveFromSelectToCreate: Observable<Void>
        var moveFromCreateToSelect: Observable<Void>
        var moveFromSelectToAdd: Observable<Void>
        var removeKeyboard: Observable<Void>
        var needDismiss: Observable<Void>
    }
    
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
    
    public func transform(input: Input) -> Output {
        
        fetchCategoryList()
        fetchGroupList()
        
        input
            .todoTitleChanged
            .skip(1)
            .bind(to: todoTitle)
            .disposed(by: bag)
        
        input
            .categorySelected
            .compactMap { $0 }
            .withUnretained(self)
            .map { vm, index in
                return vm.categorys[index]
            }
            .bind(to: todoCategory)
            .disposed(by: bag)
        
        input
            .startDayChanged
            .distinctUntilChanged()
            .bind(to: todoStartDay)
            .disposed(by: bag)
        
        input
            .endDayChanged
            .withUnretained(self)
            .subscribe(onNext: { vm, date in
                vm.todoEndDay = date
            })
            .disposed(by: bag)
        
        input
            .timeChanged
            .skip(1)
            .bind(to: todoTime)
            .disposed(by: bag)
        
        input
            .groupSelected
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.todoGroup.onNext(vm.groups[index])
            })
            .disposed(by: bag)
        
        input
            .memoChanged
            .skip(1)
            .bind(to: todoMemo)
            .disposed(by: bag)
        
        input
            .newCategoryNameChanged
            .bind(to: newCategoryName)
            .disposed(by: bag)
        
        input
            .newCategoryColorChanged
            .bind(to: newCategoryColor)
            .disposed(by: bag)
        
        input
            .didRemoveCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                vm.deleteCategory(id: id)
            })
            .disposed(by: bag)
        
        input
            .categoryEditRequested
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                guard let category = vm.categorys.first(where: { $0.id == id }) else { return }
                vm.categoryCreatingState = .edit(id)

                vm.newCategoryName.onNext(category.title)
                vm.newCategoryColor.onNext(category.color)
                vm.moveFromSelectToCreate.onNext(())
            })
            .disposed(by: bag)
        
        input
            .categorySelectBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.moveFromAddToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .todoSaveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let title = try? vm.todoTitle.value(),
                      let startDate = try? vm.todoStartDay.value(),
                      let categoryId = (try? vm.todoCategory.value())?.id else { return }
                let memo = try? vm.todoMemo.value()
                let time = try? vm.todoTime.value()
                var todo = Todo(
                    id: nil,
                    title: title,
                    startDate: startDate,
                    endDate: vm.todoEndDay ?? startDate,
                    memo: memo,
                    groupId: nil,
                    categoryId: categoryId,
                    startTime: ((time?.isEmpty) ?? true) ? nil : time
                )
                
                switch vm.todoCreateState {
                case .new:
                    vm.createTodo(todo: todo)
                case .edit(let exTodo):
                    todo.id = exTodo.id
                    vm.updateTodo(todoUpdate: TodoUpdateComparator(before: exTodo, after: todo))
                }
                
            })
            .disposed(by: bag)
        
        input
            .todoRemoveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                switch vm.todoCreateState {
                case .edit(let exTodo):
                    vm.deleteTodo(todo: exTodo)
                default:
                    return
                }
            })
            .disposed(by: bag)
        
        input
            .newCategoryAddBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.categoryCreatingState = .new
                vm.moveFromSelectToCreate.onNext(())
            })
            .disposed(by: bag)
        
        input
            .newCategorySaveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                // 1. save current edit or creating
                guard let title = try? vm.newCategoryName.value(),
                      let color = try? vm.newCategoryColor.value() else { return }
                switch vm.categoryCreatingState {
                case .new:
                    vm.saveNewCategory(category: Category(id: nil, title: title, color: color))
                case .edit(let id):
                    vm.updateCategory(category: Category(id: id, title: title, color: color))
                }
            })
            .disposed(by: bag)
        
        input
            .categorySelectPageBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.moveFromSelectToAdd.onNext(())
            })
            .disposed(by: bag)
        
        input
            .categoryCreatePageBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.moveFromCreateToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .startDayButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.removeKeyboard.onNext(())
            })
            .disposed(by: bag)
        
        input
            .endDayButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.removeKeyboard.onNext(())
            })
            .disposed(by: bag)
        
        let todoSaveBtnEnabled = Observable
            .combineLatest(
                todoTitle,
                todoCategory,
                todoStartDay
            )
            .map { (title, category, startDay) in
                guard let title,
                      let category,
                      let startDay else { return false }
                
                return !title.isEmpty
            }
        
        let newCategorySaveBtnEnabled = Observable
            .combineLatest(
                newCategoryName,
                newCategoryColor
            )
            .map { (name, color) in
                guard let name,
                      let color else { return false }
                return !name.isEmpty
            }
        
        return Output(
            categoryChanged: todoCategory.asObservable(),
            todoSaveBtnEnabled: todoSaveBtnEnabled.asObservable(),
            newCategorySaveBtnEnabled: newCategorySaveBtnEnabled.asObservable(),
            newCategorySaved: needReloadCategoryList.asObservable(),
            moveFromAddToSelect: moveFromAddToSelect.asObservable(),
            moveFromSelectToCreate: moveFromSelectToCreate.asObservable(),
            moveFromCreateToSelect: moveFromCreateToSelect.asObservable(),
            moveFromSelectToAdd: moveFromSelectToAdd.asObservable(),
            removeKeyboard: removeKeyboard.asObservable(),
            needDismiss: needDismiss.asObservable()
        )
    }
    
    func setForEdit(todo: Todo, category: Category) {
        guard let id = todo.id else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy.MM.dd"
        self.todoTitle.onNext(todo.title)
        self.todoCategory.onNext(category)
        self.todoStartDay.onNext(todo.startDate)
        // FIXME: endDate는 설정 안함 아직
        self.todoTime.onNext(todo.startTime)
        self.todoMemo.onNext(todo.memo)
        self.todoCreateState = .edit(todo)
    }
    
    func fetchCategoryList() {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Category]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.readCategoryUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.categorys = list.filter { $0.status == .active }
                self?.needReloadCategoryList.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchGroupList() {
        
    }
    
    func createTodo(todo: Todo) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.createTodoUseCase
                    .execute(token: token, todo: todo)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] id in
                var todoWithId = todo
                todoWithId.id = id
                self?.needDismiss.onNext(())
            })
            .disposed(by: bag)
    }
    
    func updateTodo(todoUpdate: TodoUpdateComparator) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateTodoUseCase
                    .execute(token: token, todoUpdate: todoUpdate)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.needDismiss.onNext(())
            })
            .disposed(by: bag)
    }
    
    func deleteTodo(todo: Todo) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.deleteTodoUseCase
                    .execute(token: token, todo: todo)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.needDismiss.onNext(())
            })
            .disposed(by: bag)
    }

    func saveNewCategory(category: Category) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.createCategoryUseCase
                    .execute(token: token, category: category)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] id in
                var categoryWithId = category
                categoryWithId.id = id

                self?.categorys.append(categoryWithId)
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
            })
            .disposed(by: bag)
    }
    
    func updateCategory(category: Category) {
        guard let id = category.id else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateCategoryUseCase
                    .execute(token: token, id: id, category: category)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] id in
                guard let index = self?.categorys.firstIndex(where: { $0.id == id }) else { return }
                self?.categorys[index] = category
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
            }, onFailure: { error in
                print(error)
            })
            .disposed(by: bag)
    }
    
    func deleteCategory(id: Int) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.deleteCategoryUseCase
                    .execute(token: token, id: id)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] in
                print("removed!!")
            })
            .disposed(by: bag)
    }
}
