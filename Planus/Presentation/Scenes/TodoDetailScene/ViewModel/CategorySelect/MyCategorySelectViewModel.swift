//
//  MyCategorySelectViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation
import RxSwift

final class MyCategorySelectViewModel: CategorySelectViewModelable {
    
    struct UseCases {
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let deleteCategoryUseCase: DeleteCategoryUseCase
    }
    
    struct Actions {
        let showCategoryCreate: ((MyCategoryDetailViewModel.Args) -> Void)?
        let pop: (() -> Void)?
        let dismiss: (() -> Void)?
    }
    
    struct Args {
        let categories: [Category]
        let categorySelected: PublishSubject<Category>
        let categoryCreated: PublishSubject<Category>
        let categoryUpdated: PublishSubject<Category>
        let categoryRemovedWithId: PublishSubject<Int>
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    private let bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    private let insertCategoryAt = PublishSubject<Int>()
    private let reloadCategoryAt = PublishSubject<Int>()
    private let removeCategoryAt = PublishSubject<Int>()
    
    // MARK: - Injected RxSubject
    private let categoryCreated: PublishSubject<Category>
    private let categoryUpdated: PublishSubject<Category>
    private let categoryRemovedWithId: PublishSubject<Int>
    
    private let showAlert = PublishSubject<Message>()
    private let categorySelected: PublishSubject<Category>
    
    var categories: [Category]
    
    required init(useCases: UseCases, injectable: Injectable) {
        self.useCases = useCases
        self.actions = injectable.actions
        self.categories = injectable.args.categories
        self.categorySelected = injectable.args.categorySelected
        self.categoryCreated = injectable.args.categoryCreated
        self.categoryUpdated = injectable.args.categoryUpdated
        self.categoryRemovedWithId = injectable.args.categoryRemovedWithId
    }
    
    func transform(input: Input) -> Output {
        bind()
        
        input
            .categoryCreateBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.showCategoryCreate()
            })
            .disposed(by: bag)
        
        input
            .categorySelectedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.selectCategory(at: index)
            })
            .disposed(by: bag)
        
        input
            .categoryEditRequiredWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                vm.showCategoryEdit(id: id)
            })
            .disposed(by: bag)
        
        input
            .categoryRemoveRequiredWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                vm.removeCategory(id: id)
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
        
        return CategorySelectViewModelOutput(
            insertCategoryAt: insertCategoryAt.asObservable(),
            reloadCategoryAt: reloadCategoryAt.asObservable(),
            removeCategoryAt: removeCategoryAt.asObservable(),
            showMessage: showAlert.asObservable()
        )
    }
}

// MARK: - bind
private extension MyCategorySelectViewModel {
    func bind() {
        categoryCreated
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                let index = vm.categories.count
                vm.categories.insert(category, at: index)
                vm.insertCategoryAt.onNext(index)
            })
            .disposed(by: bag)
        
        categoryUpdated
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let index = vm.categories.firstIndex(where: { $0.id == category.id }) else { return }
                vm.categories[index] = category
                vm.reloadCategoryAt.onNext(index)
            })
            .disposed(by: bag)
    }
}

// MARK: - 화면전환 Actions
private extension MyCategorySelectViewModel {
    func showCategoryCreate() {
        actions.showCategoryCreate?(MyCategoryDetailViewModel.Args(
            type: .new,
            categoryCreated: categoryCreated,
            categoryUpdated: categoryUpdated
        ))
    }
    
    func selectCategory(at index: Int) {
        let category = categories[index]
        categorySelected.onNext(category)
        actions.pop?()
    }
    
    func showCategoryEdit(id: Int) {
        guard let category = categories.first(where: { $0.id == id }) else { return }
        actions.showCategoryCreate?(MyCategoryDetailViewModel.Args(
            type: .edit(category),
            categoryCreated: categoryCreated,
            categoryUpdated: categoryUpdated
        ))
    }
}

// MARK: - API
private extension MyCategorySelectViewModel {
    func removeCategory(id: Int) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
        categories.remove(at: index)
        removeCategoryAt.onNext(index)
        useCases
            .executeWithTokenUseCase
            .execute { [weak self] token in
                self?.useCases
                    .deleteCategoryUseCase
                    .execute(token: token, id: id)
            }
            .subscribe(onSuccess: { [weak self] in
                self?.categoryRemovedWithId.onNext(id)
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showAlert.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}
