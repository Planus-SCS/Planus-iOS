//
//  GroupIntroduceViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import Foundation
import RxSwift

struct GroupIntroduceViewModelActions {
    var popCurrentPage: (() -> Void)?
    var didPop: (() -> Void)?
}

class GroupIntroduceViewModel {
    var bag = DisposeBag()
    var actions: GroupIntroduceViewModelActions?

    var groupTitle: String?
    var tag: String?
    var memberCount: String?
    var captin: String?
    var notice: String?
    var memberList: [Member]?
    
    var didGroupInfoFetched = BehaviorSubject<Void?>(value: nil)
    
    struct Input {
        var didTappedJoinBtn: Observable<Void>
        var didTappedBackBtn: Observable<Void>
    }
    
    struct Output {
        var didGroupInfoFetched: Observable<Void?>
    }
    
    func setActions(actions: GroupIntroduceViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        input
            .didTappedJoinBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.requestJoinGroup(id: "abc")
            })
            .disposed(by: bag)
        
        input
            .didTappedBackBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions?.popCurrentPage?()
            })
            .disposed(by: bag)
        
        return Output(didGroupInfoFetched: didGroupInfoFetched.asObservable())
    }
    
    func fetchGroupInfo(id: String) {
        didGroupInfoFetched.onNext(())
    }
    
    func requestJoinGroup(id: String) {

    }
}
