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
    
    var groupList: [JoinedGroupViewModel]? = [
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest1", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest2", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest3", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest4", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest2", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest1", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4")
    ]
    
    var didFetchedGroupList = BehaviorSubject<Void?>(value: nil)
    
    struct Input {
        var didTappedAt: Observable<Int>
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
