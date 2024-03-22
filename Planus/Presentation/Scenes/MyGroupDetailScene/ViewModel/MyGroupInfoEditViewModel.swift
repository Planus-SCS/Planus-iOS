//
//  MyGroupInfoEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import Foundation
import RxSwift

class MyGroupInfoEditViewModel: ViewModel {
    
    struct UseCases {
        let getTokenUseCase: GetTokenUseCase
        let refreshTokenUseCase: RefreshTokenUseCase
        let fetchImageUseCase: FetchImageUseCase
        let updateGroupInfoUseCase: UpdateGroupInfoUseCase
        let deleteGroupUseCase: DeleteGroupUseCase
    }
    
    struct Actions {
        let popDetailScene: (() -> Void)?
        let pop: (() -> Void)?
    }
    
    struct Args {
        let id: Int
        let title: String
        let imageUrl: String
        let tagList: [String]
        let maxMember: Int
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var groupId: Int
    var title: String
    var tagList: [String]
    var maxMember: BehaviorSubject<Int?>
    var titleImage = BehaviorSubject<ImageFile?>(value: nil)
    
    let tagCountValidState = BehaviorSubject<Bool?>(value: nil)
    let tagDuplicateValidState = BehaviorSubject<Bool?>(value: nil)

    var nowSaving = false
    
    var showMessage = PublishSubject<Message>()
    
    struct Input {
        var titleImageChanged: Observable<ImageFile?>
        var tagAdded: Observable<String>
        var tagRemovedAt: Observable<Int>
        var maxMemberChanged: Observable<String?>
        var saveBtnTapped: Observable<Void>
        var removeBtnTapped: Observable<Void>
        var backBtnTapped: Observable<Void>
    }
    
    struct Output {
        var imageFilled: Observable<Bool>
        var maxCountFilled: Observable<Bool>
        var didChangedTitleImage: Observable<Data?>
        var tagCountValidState: Observable<Bool>
        var tagDuplicateValidState: Observable<Bool>
        var isUpdateButtonEnabled: Observable<Bool>
        var insertTagAt: Observable<Int>
        var removeTagAt: Observable<Int>
        var showMessage: Observable<Message>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.groupId = injectable.args.id
        self.title = injectable.args.title
        self.tagList = injectable.args.tagList
        self.maxMember = BehaviorSubject<Int?>(value: injectable.args.maxMember)
        
        useCases
            .fetchImageUseCase
            .execute(key: injectable.args.imageUrl)
            .subscribe(onSuccess: { [weak self] data in
                self?.titleImage.onNext(ImageFile(filename: "original", data: data, type: "jpeg"))
            })
            .disposed(by: bag)
    }
    
    public func transform(input: Input) -> Output {
        let insertAt = PublishSubject<Int>()
        let removeAt = PublishSubject<Int>()
        
        checkTagValidation()
        
        input
            .titleImageChanged
            .bind(to: titleImage)
            .disposed(by: bag)
        
        input
            .maxMemberChanged
            .compactMap { $0 }
            .map { return Int($0) }
            .bind(to: maxMember)
            .disposed(by: bag)
        
        input
            .saveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                if !vm.nowSaving {
                    vm.nowSaving = true
                    vm.requestUpdateInfo()
                }
            })
            .disposed(by: bag)
        
        input
            .removeBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                if !vm.nowSaving {
                    vm.nowSaving = true
                    vm.deleteGroup()
                }
            })
            .disposed(by: bag)
        
        input
            .tagAdded
            .withUnretained(self)
            .subscribe(onNext: { vm, tag in
                vm.tagList.append(tag)
                vm.checkTagValidation()
                insertAt.onNext(vm.tagList.count - 1)
            })
            .disposed(by: bag)
        
        input
            .tagRemovedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.tagList.remove(at: index)
                vm.checkTagValidation()
                removeAt.onNext(index)
            })
            .disposed(by: bag)
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        let imageFilled = titleImage.map { $0 != nil }.asObservable()
        let maxMemberFilled = maxMember.map {
            guard let max = $0,
                  max <= 50 else { return false }
            return true
        }
        
        let isCreateButtonEnabled = Observable.combineLatest([
            imageFilled,
            maxMemberFilled,
            tagCountValidState.compactMap { $0 },
            tagDuplicateValidState.compactMap { $0 }
        ]).map { list in
            guard let _ = list.first(where: { !$0 }) else { return true }
            return false
        }
        
        return Output(
            imageFilled: imageFilled,
            maxCountFilled: maxMemberFilled,
            didChangedTitleImage: titleImage.map { $0?.data }.asObservable(),
            tagCountValidState: tagCountValidState.compactMap { $0 }.asObservable(),
            tagDuplicateValidState: tagDuplicateValidState.compactMap { $0 }.asObservable(),
            isUpdateButtonEnabled: isCreateButtonEnabled,
            insertTagAt: insertAt.asObservable(),
            removeTagAt: removeAt.asObservable(),
            showMessage: showMessage.asObservable()
        )
    }
    
    func checkTagValidation() {
        let tagCountState = tagList.count <= 5 && tagList.count > 0
        let tagDuplicateState = tagCountState && Set(tagList).count == tagList.count
        
        self.tagCountValidState.onNext(tagCountState)
        self.tagDuplicateValidState.onNext(tagDuplicateState)
    }
    
    func requestUpdateInfo() {
        guard let limit = try? maxMember.value(),
              let image = try? titleImage.value() else { return }
        useCases
            .getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.updateGroupInfoUseCase
                    .execute(token: token, groupId: self.groupId, tagList: self.tagList, limit: limit, image: image)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.nowSaving = false
                self?.actions.pop?()
            }, onFailure: { [weak self] error in
                self?.nowSaving = false
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
            
    }
    
    func deleteGroup() {
        useCases
            .getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.deleteGroupUseCase
                    .execute(token: token, groupId: self.groupId)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                // 아에 앞에 있던 네비게이션을 싹다 없애고 첫 씬으로 돌아가야함..!
                self?.actions.popDetailScene?()
                self?.nowSaving = false
            }, onFailure: { [weak self] error in
                self?.nowSaving = false
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.nowSaving = false
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}
