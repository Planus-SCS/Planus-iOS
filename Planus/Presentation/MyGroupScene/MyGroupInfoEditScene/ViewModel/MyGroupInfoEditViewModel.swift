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
    
    let tagCountValidState = PublishSubject<Bool>()
    let tagLengthValidState = PublishSubject<Bool>()
    let tagSpecialCharValidState = PublishSubject<Bool>()
    let tagDuplicateValidState = PublishSubject<Bool>()
    
    var infoUpdateCompleted = PublishSubject<Void>()
    
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
        var tagCharCountValidState: Observable<Bool>
        var tagSpecialCharValidState: Observable<Bool>
        var tagDuplicateValidState: Observable<Bool>
        var isUpdateButtonEnabled: Observable<Bool>
        var infoUpdateCompleted: Observable<Void>
        var insertTagAt: Observable<Int>
        var removeTagAt: Observable<Int>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var fetchImageUseCase: FetchImageUseCase
    var updateGroupInfoUseCase: UpdateGroupInfoUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchImageUseCase: FetchImageUseCase,
        updateGroupInfoUseCase: UpdateGroupInfoUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.updateGroupInfoUseCase = updateGroupInfoUseCase
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
            tagCountValidState,
            tagLengthValidState,
            tagSpecialCharValidState,
            tagDuplicateValidState
        ]).map { list in
            guard let _ = list.first(where: { !$0 }) else { return true }
            return false
        }
        
        return Output(
            imageFilled: imageFilled,
            maxCountFilled: maxMemberFilled,
            didChangedTitleImage: titleImage.map { $0?.data }.asObservable(),
            tagCountValidState: tagCountValidState.asObservable(),
            tagCharCountValidState: tagLengthValidState.asObservable(),
            tagSpecialCharValidState: tagSpecialCharValidState.asObservable(),
            tagDuplicateValidState: tagDuplicateValidState.asObservable(),
            isUpdateButtonEnabled: isCreateButtonEnabled,
            infoUpdateCompleted: infoUpdateCompleted.asObservable(),
            insertTagAt: insertAt.asObservable(),
            removeTagAt: removeAt.asObservable()
        )
    }
    
    func checkTagValidation() {
        let tagCountState = tagList.count <= 5 && tagList.count > 0
        let tagLengthState = tagCountState && tagList.filter { $0.count > 7 }.count == 0
        let tagSpecialCharState = tagCountState && tagList.filter { $0.checkRegex(regex: "^(?=.*[\\s!@#$%0-9])") }.count == 0
        let tagDuplicateState = tagCountState && Set(tagList).count == tagList.count
        
        self.tagCountValidState.onNext(tagCountState)
        self.tagLengthValidState.onNext(tagLengthState)
        self.tagSpecialCharValidState.onNext(tagSpecialCharState)
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
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.infoUpdateCompleted.onNext(())
            })
            .disposed(by: bag)
            
    }
}
