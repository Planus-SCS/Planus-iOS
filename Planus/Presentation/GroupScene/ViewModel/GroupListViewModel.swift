//
//  GroupListViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import Foundation
import RxSwift

struct GroupListViewModelActions {
    var showJoinedGroupDetail: ((Int) -> Void)?
}

class GroupListViewModel {
    
    var bag = DisposeBag()
    var actions: GroupListViewModelActions?
    
    var groupList: [MyGroupSummary]?
    
    var didFetchGroupList = BehaviorSubject<Void?>(value: nil)
    var didChangeOnlineStateAt = PublishSubject<Int>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var tappedAt: Observable<Int>
        var becameOnlineStateAt: Observable<Int>
        var becameOfflineStateAt: Observable<Int>
        var refreshRequired: Observable<Void>
    }
    
    struct Output {
        var didFetchJoinedGroup: Observable<Void?>
        var didChangeOnlineStateAt: Observable<Int>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUsecase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchMyGroupListUseCase: FetchMyGroupListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var groupCreateUseCase: GroupCreateUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUsecase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchMyGroupListUseCase: FetchMyGroupListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        groupCreateUseCase: GroupCreateUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUsecase = refreshTokenUsecase
        self.setTokenUseCase = setTokenUseCase
        self.fetchMyGroupListUseCase = fetchMyGroupListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.groupCreateUseCase = groupCreateUseCase
    }
    
    func setActions(actions: GroupListViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList()
            })
            .disposed(by: bag)
        
        input
            .refreshRequired
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList()
            })
            .disposed(by: bag)
        
        input
            .becameOnlineStateAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                // 벨류가 바뀌면 저짝에다가 보내고,
            })
            .disposed(by: bag)
        
        input
            .becameOfflineStateAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                
            })
            .disposed(by: bag)
        
        input
            .tappedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                guard let id = vm.groupList?[index].groupId else { return }
                vm.actions?.showJoinedGroupDetail?(id)
            })
            .disposed(by: bag)
        
        return Output(
            didFetchJoinedGroup: didFetchGroupList,
            didChangeOnlineStateAt: didChangeOnlineStateAt.asObservable())
    }
    
    func bindUseCase() {
        groupCreateUseCase
            .didCreateGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList()
            })
            .disposed(by: bag)
    }
    
    func fetchMyGroupList() {
        guard let token = getTokenUseCase.execute() else { return }

        fetchMyGroupListUseCase
            .execute(token: token)
            .subscribe(onSuccess: { [weak self] list in
                self?.groupList = list
                self?.didFetchGroupList.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
}
