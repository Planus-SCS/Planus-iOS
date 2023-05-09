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
    
    var groupId: Int?

    var groupTitle: String?
    var tag: String?
    var memberCount: String?
    var captin: String?
    var notice: String?
    var groupImageUrl: String?
    var memberList: [Member]?
    
    var didGroupInfoFetched = BehaviorSubject<Void?>(value: nil)
    var didGroupMemberFetched = BehaviorSubject<Void?>(value: nil)
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedJoinBtn: Observable<Void>
        var didTappedBackBtn: Observable<Void>
    }
    
    struct Output {
        var didGroupInfoFetched: Observable<Void?>
        var didGroupMemberFetched: Observable<Void?>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchUnJoinedGroupUseCase: FetchUnJoinedGroupUseCase
    var fetchImageUseCase: FetchImageUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchUnjoinedGroupUseCase: FetchUnJoinedGroupUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.setTokenUseCase = setTokenUseCase
        self.fetchUnJoinedGroupUseCase = fetchUnjoinedGroupUseCase
        self.fetchImageUseCase = fetchImageUseCase
    }
    
    func setGroupId(id: Int) {
        self.groupId = id
    }
    
    func setActions(actions: GroupIntroduceViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let id = vm.groupId else { return }
                vm.fetchGroupInfo(id: id)
            })
            .disposed(by: bag)
        
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
        
        return Output(
            didGroupInfoFetched: didGroupInfoFetched.asObservable(),
            didGroupMemberFetched: didGroupMemberFetched.asObservable()
        )
    }
    
    func fetchGroupInfo(id: Int) {
        guard let token = getTokenUseCase.execute() else { return }
        
        fetchUnJoinedGroupUseCase
            .execute(token: token, id: id)
            .subscribe(onSuccess: { [weak self] groupDetail in
                self?.groupTitle = groupDetail.name
                self?.tag = groupDetail.groupTags.map { "#\($0.name)" }.joined(separator: " ")
                self?.memberCount = "\(groupDetail.memberCount)/\(groupDetail.limitCount)"
                self?.captin = groupDetail.leaderName
                self?.notice = groupDetail.notice
                self?.didGroupInfoFetched.onNext(())
            })
            .disposed(by: bag)
    }
    
    func requestJoinGroup(id: String) {
        
    }
    
    func fetchImage(key: String) -> Single<Data> {
        return fetchImageUseCase
            .execute(key: key)
    }
}
