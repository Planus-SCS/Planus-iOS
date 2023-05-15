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
    
    var title = BehaviorSubject<String?>(value: nil)
    var titleImage = BehaviorSubject<ImageFile?>(value: nil)
    var tagList = BehaviorSubject<[String?]>(value: [])
    var maxMember = BehaviorSubject<Int?>(value: nil)

    var groupCreateCompleted = PublishSubject<Void>()
    
    struct Input {
        var titleChanged: Observable<String?>
        var titleImageChanged: Observable<ImageFile?>
        var tagListChanged: Observable<[String?]>
        var maxMemberChanged: Observable<String?>
        var saveBtnTapped: Observable<Void>
    }
    
    struct Output {
        var titleFilled: Observable<Bool>
        var imageFilled: Observable<Bool>
        var maxCountFilled: Observable<Bool>
        var didChangedTitleImage: Observable<Data?>
        var tagCountValidState: Observable<Bool>
        var tagCharCountValidState: Observable<Bool>
        var tagSpecialCharValidState: Observable<Bool>
        var isCreateButtonEnabled: Observable<Bool>
        var groupCreateCompleted: Observable<Void>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
    }
    
    public func setGroupId(id: Int) {
        self.groupId = id
    }
    
    public func transform(input: Input) -> Output {
        let tagCountValidState = tagList
            .map { list in
                let nonNilList = list.filter { $0 != nil }
                return nonNilList.count <= 5 && nonNilList.count > 0
            }
        
        let tagCharCountValidState = Observable.zip(tagList, tagCountValidState)
            .map { (list, countValid) in
                guard countValid else {
                    return false
                }
                for i in (0..<list.count) {
                    if let tag = list[i],
                       tag.count > 7 {
                        return false
                    }
                }
                return true
            }
        
        let tagSpecialCharValidState = Observable.zip(tagList, tagCountValidState)
            .map { (list, countValid) in
                guard countValid else {
                    return false
                }
                for i in (0..<list.count) {
                    if let tag = list[i],
                       tag.checkRegex(regex: "^(?=.*[\\s!@#$%0-9])") {
                       return false
                    }
                }
                return true
            }
        input
            .titleChanged
            .bind(to: title)
            .disposed(by: bag)

        input
            .titleImageChanged
            .bind(to: titleImage)
            .disposed(by: bag)
        
        input
            .tagListChanged
            .bind(to: tagList)
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
                /*
                 update!
                 */
            })
            .disposed(by: bag)
        
        let titleFilled = title.map{ !(($0?.isEmpty) ?? true) }.asObservable()
        let imageFilled = titleImage.map { $0 != nil }.asObservable()
        let maxMemberFilled = maxMember.map {
            guard let max = $0,
                  max <= 50 else { return false }
            return true
        }
        
        let isCreateButtonEnabled = Observable.combineLatest([
            titleFilled,
            imageFilled,
            maxMemberFilled,
            tagCountValidState,
            tagCharCountValidState,
            tagSpecialCharValidState
        ]).map { list in
            guard let _ = list.first(where: { !$0 }) else { return true }
            return false
        }
        
        return Output(
            titleFilled: titleFilled,
            imageFilled: imageFilled,
            maxCountFilled: maxMemberFilled,
            didChangedTitleImage: titleImage.map { $0?.data }.asObservable(),
            tagCountValidState: tagCountValidState.asObservable(),
            tagCharCountValidState: tagCharCountValidState.asObservable(),
            tagSpecialCharValidState: tagSpecialCharValidState.asObservable(),
            isCreateButtonEnabled: isCreateButtonEnabled,
            groupCreateCompleted: groupCreateCompleted.asObservable()
        )
    }
}
