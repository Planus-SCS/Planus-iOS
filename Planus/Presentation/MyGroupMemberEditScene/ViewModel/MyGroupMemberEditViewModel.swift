//
//  MyGroupMemberEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class MyGroupMemberEditViewModel {
    
    var bag = DisposeBag()
    
    var groupId: Int?
    var memberList: [Member]?
    
    struct Input {
        var didTappedResignButton: Observable<String>
    }
    
    struct Output {
        var didRequestResign: Observable<Void>
        var didResignedAt: Observable<Int>
    }
    
    var resignRequested = PublishSubject<Void>()
    var resignedAt = PublishSubject<Int>()
    
    init() {}
    
    func setGroupId(id: Int) {
        self.groupId = id
    }
    
    func transform(input: Input) -> Output {
        input
            .didTappedResignButton
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                vm.resignMember(id: id)
            })
            .disposed(by: bag)
        
        return Output(
            didRequestResign: resignRequested.asObservable(),
            didResignedAt: resignedAt.asObservable()
        )
    }
    
    func setMemberList(memberList: [Member]) {
        self.memberList = memberList
    }
    
    func resignMember(id: String) {
        resignRequested.onNext(())
        guard let index = memberList?.firstIndex(where: { $0.name == id }) else { return }
        memberList?.remove(at: index)
        resignedAt.onNext(index)
    }
    
}
