//
//  GroupListViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import Foundation
import RxSwift

struct GroupListViewModelActions {
    var showJoinedGroupDetail: ((String) -> Void)?
}

class GroupListViewModel {
    
    var bag = DisposeBag()
    var actions: GroupListViewModelActions?
    
    var groupList: [MyGroupSummary]?
    
    var didFetchedGroupList = BehaviorSubject<Void?>(value: nil)
    
    struct Input {
        var didTappedAt: Observable<Int>
        var didChangedOnlineStateAt: Observable<Int>
    }
    
    struct Output {
        var didFetchedJoinedGroup: Observable<Void?>
    }
    
    init() {}
    
    func setActions(actions: GroupListViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        input
            .didTappedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                guard let list = vm.groupList else { return }
                let id = list[index].id
                vm.actions?.showJoinedGroupDetail?(id)
            })
            .disposed(by: bag)
        return Output(didFetchedJoinedGroup: didFetchedGroupList)
    }
    
    func fetchGroupList() {
        didFetchedGroupList.onNext(())
    }
}
