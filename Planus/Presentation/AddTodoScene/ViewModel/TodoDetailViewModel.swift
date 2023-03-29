//
//  AddTodoViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation
import RxSwift

final class AddTodoViewModel {
    var bag = DisposeBag()
    
    var categorys: [TodoCategory] = [
        TodoCategory(title: "카테고리1", color: .blue),
        TodoCategory(title: "카테고리2", color: .gold),
        TodoCategory(title: "카테고리3", color: .green),
        TodoCategory(title: "카테고리4", color: .navy),
        TodoCategory(title: "카테고리5", color: .pink),
        TodoCategory(title: "카테고리6", color: .yello)
    ]
    
    var groups: [String] = [
        "group1", "group2"
    ]
    
    
    var todoTitle = BehaviorSubject<String?>(value: nil)
    var todoCategory = BehaviorSubject<TodoCategory?>(value: nil)
    var todoStartDay = BehaviorSubject<Date?>(value: nil)
    var todoEndDay: Date?
    var todoGroup: String?
    var todoMemo: String?
    
    var newCategoryName = BehaviorSubject<String?>(value: nil)
    var newCategoryColor = BehaviorSubject<TodoCategoryColor?>(value: nil)
    
    struct Input {
        // MARK: Control Value
        var todoTitleChanged: Observable<String?>
        var categoryChanged: Observable<Int?>
        var startDayChanged: Observable<Date?>
        var endDayChanged: Observable<Date?>
        var groupSelected: Observable<Int?>
        var memoChanged: Observable<String?>
        var newCategoryNameChanged: Observable<String?>
        var newCategoryColorChanged: Observable<TodoCategoryColor?>
        
        // MARK: Control Event
        var categorySelectBtnTapped: Observable<Void>
        var todoSaveBtnTapped: Observable<Void>
        var newCategoryAddBtnTapped: Observable<Void>
        var newCategorySaveBtnTapped: Observable<Void>
        var categorySelectPageBackBtnTapped: Observable<Void>
        var categoryCreatePageBackBtnTapped: Observable<Void>
    }
    
    struct Output {
        var todoSaveBtnEnabled: Observable<Bool>
        var newCategorySaveBtnEnabled: Observable<Bool>
        var moveFromAddToSelect: Observable<Void>
        var moveFromSelectToCreate: Observable<Void>
        var moveFromCreateToSelect: Observable<Void>
        var moveFromSelectToAdd: Observable<Void>
    }
    
    init() {}
    
    public func transform(input: Input) -> Output {
        
        let moveFromAddToSelect = PublishSubject<Void>()
        let moveFromSelectToCreate = PublishSubject<Void>()
        let moveFromCreateToSelect = PublishSubject<Void>()
        let moveFromSelectToAdd = PublishSubject<Void>()
        
        input
            .todoTitleChanged
            .bind(to: todoTitle)
            .disposed(by: bag)
        
        input
            .categoryChanged
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
            .categorySelectBtnTapped
            .subscribe(onNext: {
                moveFromAddToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .todoSaveBtnTapped
            .subscribe(onNext: {
                
            })
            .disposed(by: bag)
        
        input
            .newCategoryAddBtnTapped
            .subscribe(onNext: {
                moveFromSelectToCreate.onNext(())
            })
            .disposed(by: bag)
        
        input
            .newCategorySaveBtnTapped
            .subscribe(onNext: {
                moveFromCreateToSelect.onNext(())
                // 리로드 하라고 전달해야함!!!!! 아님 insert나 reloadItem
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
        
        let todoSaveBtnEnabled = Observable
            .combineLatest(
                todoTitle.compactMap { $0 },
                todoCategory.compactMap { $0 },
                todoStartDay.compactMap { $0 }
            )
            .map { (title, category, startDay) in
                print("hihi")
                return title.isEmpty
            }
        
        let newCategorySaveBtnEnabled = Observable
            .combineLatest(
                newCategoryName.compactMap { $0 },
                newCategoryColor.compactMap { $0 }
            )
            .map { (name, color) in
                print("fuck")
                return name.isEmpty
            }
        return Output(
            todoSaveBtnEnabled: todoSaveBtnEnabled,
            newCategorySaveBtnEnabled: newCategorySaveBtnEnabled,
            moveFromAddToSelect: moveFromAddToSelect,
            moveFromSelectToCreate: moveFromSelectToCreate,
            moveFromCreateToSelect: moveFromCreateToSelect,
            moveFromSelectToAdd: moveFromSelectToAdd
        )
    }

    func saveNewCategory() {
        /*
         네트워크로 보낼 useCase 만들기
         */
    }
    
    func saveNewTodo() {
        /*
         네트워크로 보낼 useCase 만들기
         */
    }

}
