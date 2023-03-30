//
//  GroupIntroduceViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import Foundation
import RxSwift
class GroupIntroduceViewModel {
    var bag = DisposeBag()
    
    var groupTitle: String?
    var tag: String?
    var notice: String?
    var memberList: [Member]?
    
    var didGroupInfoFetched = BehaviorSubject<Void?>(value: nil)
    struct Input {
        var didTappedJoinBtn: Observable<Void>
    }
    
    struct Output {
        var didGroupInfoFetched: Observable<Void?>
    }
    
    func transform(input: Input) -> Output {
        input
            .didTappedJoinBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.requestJoinGroup(id: "abc")
            })
            .disposed(by: bag)
        return Output(didGroupInfoFetched: didGroupInfoFetched.asObservable())
    }
    
    func fetchGroupInfo(id: String) {
        
    }
    
    func requestJoinGroup(id: String) {
        
    }
}
