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

final class TodoDetailViewModel {
    var bag = DisposeBag()
    
    var completionHandler: ((Todo) -> Void)?
    
    var categoryColorList: [CategoryColor] = Array(CategoryColor.allCases[0..<CategoryColor.allCases.count-1])
    
    var categorys: [Category] = [
        Category(id: 1, title: "카테고리1", color: .blue),
        Category(id: 2, title: "카테고리2", color: .gold),
        Category(id: 3, title: "카테고리3", color: .green),
        Category(id: 4, title: "카테고리4", color: .navy),
        Category(id: 5, title: "카테고리5", color: .pink),
        Category(id: 6, title: "카테고리6", color: .yello)
    ]
    
    var categoryCreatingState: CategoryCreateState = .new
    
    var groups: [String] = [
        "group1", "group2"
    ]
    
    
    var todoTitle = BehaviorSubject<String?>(value: nil)
    var todoCategory = BehaviorSubject<Category?>(value: nil)
    var todoStartDay = BehaviorSubject<Date?>(value: nil)
    var todoEndDay: Date?
    var todoGroup: String?
    var todoMemo: String?
    
    var needDismiss = PublishSubject<Void>()
    
    var newCategoryName = BehaviorSubject<String?>(value: nil)
    var newCategoryColor = BehaviorSubject<CategoryColor?>(value: nil)
    
    struct Input {
        // MARK: Control Value
        var todoTitleChanged: Observable<String?>
        var categorySelected: Observable<Int?>
        var startDayChanged: Observable<Date?>
        var endDayChanged: Observable<Date?>
        var groupSelected: Observable<Int?>
        var memoChanged: Observable<String?>
        var newCategoryNameChanged: Observable<String?>
        var newCategoryColorChanged: Observable<CategoryColor?>
        
        // MARK: Control Event
        var categoryEditRequested: Observable<Int>
        var startDayButtonTapped: Observable<Void>
        var endDayButtonTapped: Observable<Void>
        var categorySelectBtnTapped: Observable<Void>
        var todoSaveBtnTapped: Observable<Void>
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
    var createCategoryUseCase: CreateCategoryUseCase
    var updateCategoryUseCase: UpdateCategoryUseCase
    var deleteCategoryUseCase: DeleteCategoryUseCase
    var readCategoryUseCase: ReadCategoryListUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createTodoUseCase: CreateTodoUseCase,
        createCategoryUseCase: CreateCategoryUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase,
        readCategoryUseCase: ReadCategoryListUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.createTodoUseCase = createTodoUseCase
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.readCategoryUseCase = readCategoryUseCase
    }
    
    public func transform(input: Input) -> Output {
        
        let moveFromAddToSelect = PublishSubject<Void>()
        let moveFromSelectToCreate = PublishSubject<Void>()
        let moveFromCreateToSelect = PublishSubject<Void>()
        let moveFromSelectToAdd = PublishSubject<Void>()
        let newCategorySaved = PublishSubject<Void>()
        let removeKeyboard = PublishSubject<Void>()
        
        input
            .todoTitleChanged
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
            .groupSelected
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.todoGroup = vm.groups[index]
            })
            .disposed(by: bag)
        
        input
            .memoChanged
            .withUnretained(self)
            .subscribe(onNext: { vm, memo in
                vm.todoMemo = memo
            })
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
            .categoryEditRequested
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.categoryCreatingState = .edit(index)
                vm.newCategoryName.onNext(vm.categorys[index].title)
                vm.newCategoryColor.onNext(vm.categorys[index].color)
                moveFromSelectToCreate.onNext(())
            })
            .disposed(by: bag)
        
        input
            .categorySelectBtnTapped
            .subscribe(onNext: {
                moveFromAddToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .todoSaveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let title = try? vm.todoTitle.value(),
                      let startDate = try? vm.todoStartDay.value(),
                      let category = try? vm.todoCategory.value() else { return }
                let todo = Todo(id: nil, title: title, startDate: startDate, endDate: vm.todoEndDay ?? startDate, memo: vm.todoMemo, groupId: nil, categoryId: category.id ?? 0, startTime: nil)
                vm.createTodo(todo: todo)
            })
            .disposed(by: bag)
        
        input
            .newCategoryAddBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.categoryCreatingState = .new
                moveFromSelectToCreate.onNext(())
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
                    vm.categorys.append(Category(title: title, color: color))
                case .edit(let index):
                    vm.categorys[index] = Category(title: title, color: color)
                }
                // 이제 뒤로 가게해야함. 근데 리로드를 곁들인
                newCategorySaved.onNext(())
                moveFromCreateToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .categorySelectPageBackBtnTapped
            .subscribe(onNext: {
                moveFromSelectToAdd.onNext(())
            })
            .disposed(by: bag)
        
        input
            .categoryCreatePageBackBtnTapped
            .subscribe(onNext: {
                moveFromCreateToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .startDayButtonTapped
            .subscribe(onNext: {
                removeKeyboard.onNext(())
            })
            .disposed(by: bag)
        
        input
            .endDayButtonTapped
            .subscribe(onNext: {
                removeKeyboard.onNext(())
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
            newCategorySaved: newCategorySaved.asObservable(),
            moveFromAddToSelect: moveFromAddToSelect.asObservable(),
            moveFromSelectToCreate: moveFromSelectToCreate.asObservable(),
            moveFromCreateToSelect: moveFromCreateToSelect.asObservable(),
            moveFromSelectToAdd: moveFromSelectToAdd.asObservable(),
            removeKeyboard: removeKeyboard.asObservable(),
            needDismiss: needDismiss.asObservable()
        )
    }
    
    func createTodo(todo: Todo) {
        guard let token = getTokenUseCase.execute() else { return }
        
        createTodoUseCase
            .execute(token: token, todo: todo)
            .subscribe(onSuccess: { [weak self] id in
                var todoWithId = todo
                todoWithId.id = id
                self?.completionHandler?(todoWithId)
                self?.needDismiss.onNext(())
            })
            .disposed(by: bag)
    }

    func saveNewCategory(category: Category) {
        /*
         네트워크로 보낼 useCase 만들기
         */
        guard let token = getTokenUseCase.execute() else { return }
        
        createCategoryUseCase
            .execute(token: token, category: category)
            .subscribe(onSuccess: { id in
                var categoryWithId = category
                categoryWithId.id = id
                // 카테고리 id를 받아옴,,, 그다음엔..?
                
            })
            .disposed(by: bag)
    }
}
