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
    var needReloadItemAt = PublishSubject<Int>()
    
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
        var needReloadItemAt: Observable<Int>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUsecase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchMyGroupListUseCase: FetchMyGroupListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var groupCreateUseCase: GroupCreateUseCase
    var setOnlineUseCase: SetOnlineUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUsecase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchMyGroupListUseCase: FetchMyGroupListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        groupCreateUseCase: GroupCreateUseCase,
        setOnlineUseCase: SetOnlineUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUsecase = refreshTokenUsecase
        self.setTokenUseCase = setTokenUseCase
        self.fetchMyGroupListUseCase = fetchMyGroupListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.groupCreateUseCase = groupCreateUseCase
        self.setOnlineUseCase = setOnlineUseCase
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
                vm.setOnline(index: index)
            })
            .disposed(by: bag)
        
        input
            .becameOfflineStateAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.setOnline(index: index)
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
            didChangeOnlineStateAt: didChangeOnlineStateAt.asObservable(),
            needReloadItemAt: needReloadItemAt.asObservable()
        )
    }
    
    func bindUseCase() {
        groupCreateUseCase
            .didCreateGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList()
            })
            .disposed(by: bag)
        
        setOnlineUseCase
            .didChangeOnlineState
            .withUnretained(self)
            .subscribe(onNext: { vm, groupId in
                guard let index = vm.groupList?.firstIndex(where: { $0.groupId == groupId }),
                      var group = vm.groupList?[index] else { return }
                
                group.isOnline = !group.isOnline
                group.totalCount = group.isOnline ? group.totalCount + 1 : group.totalCount - 1
                vm.groupList?[index] = group
                vm.needReloadItemAt.onNext(index)
            })
            .disposed(by: bag)
    }
    
    func setOnline(index: Int) {
        guard let token = getTokenUseCase.execute(),
              let groupId = self.groupList?[index].groupId  else { return }
        
        setOnlineUseCase
            .execute(token: token, groupId: groupId)
            .subscribe(onSuccess: { [weak self] _ in
                // 처리를 유즈케이스 바인딩을 통해 하고있음.
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
