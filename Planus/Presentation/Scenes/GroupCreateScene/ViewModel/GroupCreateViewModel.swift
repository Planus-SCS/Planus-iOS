//
//  GroupCreateViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class GroupCreateViewModel: ViewModel {
    
    struct UseCases {
        let getTokenUseCase: GetTokenUseCase
        let refreshTokenUseCase: RefreshTokenUseCase
        let groupCreateUseCase: GroupCreateUseCase
    }
    
    struct Actions {
        let showGroupCreateLoadPage: ((MyGroupCreationInfo, ImageFile) -> Void)?
        let pop: (() -> Void)?
        let finishScene: (() -> Void)?
    }
    
    struct Args {}
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var title = BehaviorSubject<String?>(value: nil)
    var notice = BehaviorSubject<String?>(value: nil)
    var titleImage = BehaviorSubject<ImageFile?>(value: nil)
    var tagList = [String]()
    var maxMember = BehaviorSubject<Int?>(value: nil)
    
    let tagCountValidState = PublishSubject<Bool>()
    let tagDuplicateValidState = PublishSubject<Bool>()

    var nowSaving = false
    var initialTagPopedOver = true
    
    struct Input {
        var titleChanged: Observable<String?>
        var noticeChanged: Observable<String?>
        var titleImageChanged: Observable<ImageFile?>
        var tagAdded: Observable<String>
        var tagRemovedAt: Observable<Int>
        var maxMemberChanged: Observable<String?>
        var saveBtnTapped: Observable<Void>
    }
    
    struct Output {
        var titleFilled: Observable<Bool>
        var noticeFilled: Observable<Bool>
        var imageFilled: Observable<Bool>
        var maxCountFilled: Observable<Bool>
        var didChangedTitleImage: Observable<Data?>
        var tagCountValidState: Observable<Bool>
        var tagDuplicateValidState: Observable<Bool>
        var isCreateButtonEnabled: Observable<Bool>
        var insertTagAt: Observable<Int>
        var remvoeTagAt: Observable<Int>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
    }
    
    func transform(input: Input) -> Output {
        let insertAt = PublishSubject<Int>()
        let removeAt = PublishSubject<Int>()

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
            .titleChanged
            .bind(to: title)
            .disposed(by: bag)
        
        input
            .noticeChanged
            .bind(to: notice)
            .disposed(by: bag)
        
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
                    vm.createGroup()
                }
            })
            .disposed(by: bag)
        
        let titleFilled = title.map{ !(($0?.isEmpty) ?? true) }.asObservable()
        let noticeFilled = notice.map { !(($0?.isEmpty) ?? true) }.asObservable()
        let imageFilled = titleImage.map { $0 != nil }.asObservable()
        let maxMemberFilled = maxMember.map {
            guard let max = $0,
                  max <= 50 else { return false }
            return true
        }
        
        let isCreateButtonEnabled = Observable.combineLatest([
            titleFilled,
            noticeFilled,
            imageFilled,
            maxMemberFilled,
            tagCountValidState,
            tagDuplicateValidState
        ]).map { list in
            guard let _ = list.first(where: { !$0 }) else { return true }
            return false
        }

        
        return Output(
            titleFilled: titleFilled,
            noticeFilled: noticeFilled,
            imageFilled: imageFilled,
            maxCountFilled: maxMemberFilled,
            didChangedTitleImage: titleImage.map { $0?.data }.asObservable(),
            tagCountValidState: tagCountValidState.asObservable(),
            tagDuplicateValidState: tagDuplicateValidState.asObservable(),
            isCreateButtonEnabled: isCreateButtonEnabled,
            insertTagAt: insertAt.asObservable(),
            remvoeTagAt: removeAt.asObservable()
        )
    }
    
    func checkTagValidation() {
        let tagCountState = tagList.count <= 5 && tagList.count > 0
        let tagDuplicateState = tagCountState && Set(tagList).count == tagList.count
        
        self.tagCountValidState.onNext(tagCountState)
        self.tagDuplicateValidState.onNext(tagDuplicateState)
    }
    
    func createGroup() {
        guard let name = try? title.value(),
              let notice = try? notice.value(),
              let limitCount = try? maxMember.value(),
              let image = try? titleImage.value() else { return }
        let tagMapped = tagList.map { GroupTag(name: $0) }
        let groupCreate = MyGroupCreationInfo(
            name: name,
            notice: notice,
            tagList: tagMapped,
            limitCount: limitCount
        )
        actions.showGroupCreateLoadPage?(groupCreate, image)
    }
}
