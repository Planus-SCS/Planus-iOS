//
//  MyCategoryDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation
import RxSwift

final class MyCategoryDetailViewModel: CategoryDetailViewModelable {
    
    enum `Type` {
        case new
        case edit(Category) // category
    }
    
    struct UseCases {
        let executeTokenUseCase: ExecuteWithTokenUseCase
        let createCategoryUseCase: CreateCategoryUseCase
        let updateCategoryUseCase: UpdateCategoryUseCase
    }
    
    struct Actions {
        var pop: (() -> Void)?
        var dismiss: (() -> Void)?
    }
    
    struct Args {
        let type: `Type`
        let categoryCreated: PublishSubject<Category>
        let categoryUpdated: PublishSubject<Category>
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    private let bag = DisposeBag()
    let useCases: UseCases
    let actions: Actions
    
    let categoryColorList: [CategoryColor] = CategoryColor.allCases
    
    private let categoryTitle = BehaviorSubject<String?>(value: nil)
    private let categoryColor = BehaviorSubject<CategoryColor?>(value: nil)
    private let type: `Type`
    
    // MARK: - Injected RxSubject
    private let categoryCreated: PublishSubject<Category>
    private let categoryUpdated: PublishSubject<Category>
    
    let showMessage = PublishSubject<Message>()
    
    init(useCases: UseCases, injectable: Injectable) {
        self.useCases = useCases
        self.actions = injectable.actions
        self.categoryCreated = injectable.args.categoryCreated
        self.categoryUpdated = injectable.args.categoryUpdated
        
        self.type = injectable.args.type
        switch injectable.args.type {
        case .edit(let category):
            self.categoryColor.onNext(category.color)
            self.categoryTitle.onNext(category.title)
        default:
            return
        }
    }
    
    func transform(input: Input) -> Output {
        input
            .categoryColorSelected
            .bind(to: categoryColor)
            .disposed(by: bag)
        
        input
            .categoryTitleChanged
            .bind(to: categoryTitle)
            .disposed(by: bag)
        
        input
            .saveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.saveCategory()
            })
            .disposed(by: bag)
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        input
            .needDismiss
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.dismiss?()
            })
            .disposed(by: bag)
        
        let newCategorySaveBtnEnabled = Observable
            .combineLatest(
                categoryTitle,
                categoryColor
            )
            .map { (name, color) in
                guard let name,
                      let color else { return false }
                return !name.isEmpty
            }
        
        return Output(
            categoryTitleValue: try? categoryTitle.value(),
            categoryColorIndexValue: categoryColorList.firstIndex(where: { $0 == (try? categoryColor.value()) }),
            saveBtnEnabled: newCategorySaveBtnEnabled,
            showMessage: showMessage.asObservable()
        )
    }
}

// MARK: - Button Action
private extension MyCategoryDetailViewModel {
    func saveCategory() {
        guard let title = try? categoryTitle.value(),
              let color = try? categoryColor.value() else { return }
        var category = Category(title: title, color: color)
        switch type {
        case .new:
            createCategory(category: category)
        case .edit(let oldValue):
            guard let id = oldValue.id else { return }
            updateCategory(id: id, category: category)
        }
    }
}

// MARK: - API
private extension MyCategoryDetailViewModel {
    func createCategory(category: Category) {
        useCases
            .executeTokenUseCase
            .execute { [weak self] token -> Single<Category>? in
                self?.useCases
                    .createCategoryUseCase
                    .execute(token: token, category: category)
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] newCategory in
                self?.categoryCreated.onNext(newCategory)
                self?.actions.pop?()
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func updateCategory(id: Int, category: Category) {
        useCases
            .executeTokenUseCase
            .execute { [weak self] token -> Single<Category>? in
                self?.useCases
                    .updateCategoryUseCase
                    .execute(token: token, id: id, category: category)
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] newCategory in
                self?.categoryUpdated.onNext(newCategory)
                self?.actions.pop?()
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}
