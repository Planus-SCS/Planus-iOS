//
//  MyGroupInfoEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import Foundation
import RxSwift

class MyGroupInfoEditViewModel {
    var bag = DisposeBag()
    var groupId: Int?
    
    var title: String?
    var titleImage = BehaviorSubject<ImageFile?>(value: nil)
    var tagList = [String]()
    var maxMember = BehaviorSubject<Int?>(value: nil)
    
    let tagCountValidState = BehaviorSubject<Bool?>(value: nil)
    let tagDuplicateValidState = BehaviorSubject<Bool?>(value: nil)
    
    var infoUpdateCompleted = PublishSubject<Void>()
    var groupDeleted = PublishSubject<Void>()
    
    struct Input {
        var titleImageChanged: Observable<ImageFile?>
        var tagAdded: Observable<String>
        var tagRemovedAt: Observable<Int>
        var maxMemberChanged: Observable<String?>
        var saveBtnTapped: Observable<Void>
    }
    
    struct Output {
        var imageFilled: Observable<Bool>
        var maxCountFilled: Observable<Bool>
        var didChangedTitleImage: Observable<Data?>
        var tagCountValidState: Observable<Bool>
        var tagDuplicateValidState: Observable<Bool>
        var isUpdateButtonEnabled: Observable<Bool>
        var infoUpdateCompleted: Observable<Void>
        var insertTagAt: Observable<Int>
        var removeTagAt: Observable<Int>
        var groupDeleted: Observable<Void>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var fetchImageUseCase: FetchImageUseCase
    var updateGroupInfoUseCase: UpdateGroupInfoUseCase
    var deleteGroupUseCase: DeleteGroupUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchImageUseCase: FetchImageUseCase,
        updateGroupInfoUseCase: UpdateGroupInfoUseCase,
        deleteGroupUseCase: DeleteGroupUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.updateGroupInfoUseCase = updateGroupInfoUseCase
        self.deleteGroupUseCase = deleteGroupUseCase
    }
    
    public func setGroup(
        id: Int,
        title: String,
        imageUrl: String,
        tagList: [String],
        maxMember: Int
    ) {
        self.groupId = id
        self.title = title
        self.tagList = tagList
        self.maxMember.onNext(maxMember)
        
        fetchImageUseCase
            .execute(key: imageUrl)
            .subscribe(onSuccess: { [weak self] data in
                self?.titleImage.onNext(ImageFile(filename: "original", data: data, type: "png"))
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
                vm.requestUpdateInfo()
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
            infoUpdateCompleted: infoUpdateCompleted.asObservable(),
            insertTagAt: insertAt.asObservable(),
            removeTagAt: removeAt.asObservable(),
            groupDeleted: groupDeleted.asObserver()
        )
    }
    
    func checkTagValidation() {
        let tagCountState = tagList.count <= 5 && tagList.count > 0
        let tagDuplicateState = tagCountState && Set(tagList).count == tagList.count
        
        self.tagCountValidState.onNext(tagCountState)
        self.tagDuplicateValidState.onNext(tagDuplicateState)
    }
    
    func requestUpdateInfo() {
        guard let groupId,
              let limit = try? maxMember.value(),
              let image = try? titleImage.value() else { return }
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateGroupInfoUseCase
                    .execute(token: token, groupId: groupId, tagList: self.tagList, limit: limit, image: image)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.infoUpdateCompleted.onNext(())
            })
            .disposed(by: bag)
            
    }
    
    func deleteGroup() {
        guard let groupId else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.deleteGroupUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                // 아에 앞에 있던 네비게이션을 싹다 없애고 첫 씬으로 돌아가야함..!
                self?.groupDeleted.onNext(())
            })
            .disposed(by: bag)
    }
}
