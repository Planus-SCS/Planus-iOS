//
//  GroupCreateViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class GroupCreateViewModel {
    
    var bag = DisposeBag()
    
    var title = BehaviorSubject<String?>(value: nil)
    var notice = BehaviorSubject<String?>(value: nil)
    var titleImage = BehaviorSubject<ImageFile?>(value: nil)
    var tagList = BehaviorSubject<[String?]>(value: [])
    var maxMember = BehaviorSubject<Int?>(value: nil)

    
    struct Input {
        var titleChanged: Observable<String?>
        var noticeChanged: Observable<String?>
        var titleImageChanged: Observable<ImageFile?>
        var tagListChanged: Observable<[String?]>
        var maxMemberChanged: Observable<String?>
    }
    
    struct Output {
        var titleFilled: Observable<Bool>
        var noticeFilled: Observable<Bool>
        var imageFilled: Observable<Bool>
        var maxCountFilled: Observable<Bool>
        var didChangedTitleImage: Observable<Data?>
        var tagCountValidState: Observable<Bool>
        var tagCharCountValidState: Observable<Bool>
        var tagSpecialCharValidState: Observable<Bool>
        var isCreateButtonEnabled: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
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
            .noticeChanged
            .bind(to: notice)
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
            tagCharCountValidState,
            tagSpecialCharValidState
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
            tagCharCountValidState: tagCharCountValidState.asObservable(),
            tagSpecialCharValidState: tagSpecialCharValidState.asObservable(),
            isCreateButtonEnabled: isCreateButtonEnabled
        )
    }
    
}
