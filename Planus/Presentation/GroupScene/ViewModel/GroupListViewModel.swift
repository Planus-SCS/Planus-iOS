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
            didFetchJoinedGroup: didFetchGroupList.asObservable(),
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

                group.onlineCount = group.isOnline ? group.onlineCount + 1 : group.onlineCount - 1
                vm.groupList?[index] = group
                vm.needReloadItemAt.onNext(index)
            })
            .disposed(by: bag)
    }
    
    func setOnline(index: Int) {
        guard let groupId = self.groupList?[index].groupId  else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.setOnlineUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUsecase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onError: { [weak self] _ in
                self?.needReloadItemAt.onNext(index)
            })
            .disposed(by: bag)
    }
    
    func fetchMyGroupList() {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[MyGroupSummary]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupListUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUsecase.execute(),
                errorType: TokenError.noTokenExist
            )
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
