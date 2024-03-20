//
//  MyGroupListViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import Foundation
import RxSwift

struct GroupListViewModelActions {
    var showJoinedGroupDetail: ((Int) -> Void)?
}

class MyGroupListViewModel {
    
    var bag = DisposeBag()
    var actions: GroupListViewModelActions?
    
    var groupList: [MyGroupSummary]?
    
    var didStartFetching = BehaviorSubject<Void?>(value: nil)
    var didFetchGroupList = BehaviorSubject<FetchType?>(value: nil)
    var needReloadItemAt = PublishSubject<Int>()
    var didSuccessOnlineStateChange = PublishSubject<(Int, Bool)>() //index, isSuccess
    var showMessage = PublishSubject<String>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var tappedAt: Observable<Int>
        var becameOnlineStateAt: Observable<Int>
        var becameOfflineStateAt: Observable<Int>
        var refreshRequired: Observable<Void>
    }
    
    struct Output {
        var didStartFetching: Observable<Void?>
        var didFetchJoinedGroup: Observable<FetchType?>
        var needReloadItemAt: Observable<Int>
        var showMessage: Observable<String>
        var didSuccessOnlineStateChange: Observable<(Int, Bool)>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUsecase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchMyGroupListUseCase: FetchMyGroupListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var groupCreateUseCase: GroupCreateUseCase
    var setOnlineUseCase: SetOnlineUseCase
    var updateGroupInfoUseCase: UpdateGroupInfoUseCase
    var withdrawGroupUseCase: WithdrawGroupUseCase
    var deleteGroupUseCase: DeleteGroupUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUsecase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchMyGroupListUseCase: FetchMyGroupListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        groupCreateUseCase: GroupCreateUseCase,
        setOnlineUseCase: SetOnlineUseCase,
        updateGroupInfoUseCase: UpdateGroupInfoUseCase,
        withdrawGroupUseCase: WithdrawGroupUseCase,
        deleteGroupUseCase: DeleteGroupUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUsecase = refreshTokenUsecase
        self.setTokenUseCase = setTokenUseCase
        self.fetchMyGroupListUseCase = fetchMyGroupListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.groupCreateUseCase = groupCreateUseCase
        self.setOnlineUseCase = setOnlineUseCase
        self.updateGroupInfoUseCase = updateGroupInfoUseCase
        self.withdrawGroupUseCase = withdrawGroupUseCase
        self.deleteGroupUseCase = deleteGroupUseCase
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
                vm.fetchMyGroupList(fetchType: .initail)
            })
            .disposed(by: bag)
        
        input
            .refreshRequired
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList(fetchType: .refresh)
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
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                guard let id = vm.groupList?[index].groupId else { return }
                vm.actions?.showJoinedGroupDetail?(id)
            })
            .disposed(by: bag)
        
        return Output(
            didStartFetching: didStartFetching.asObservable(),
            didFetchJoinedGroup: didFetchGroupList.asObservable(),
            needReloadItemAt: needReloadItemAt.asObservable(),
            showMessage: showMessage.asObservable(),
            didSuccessOnlineStateChange: didSuccessOnlineStateChange.asObservable()
        )
    }
    
    func bindUseCase() {
        groupCreateUseCase
            .didCreateGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList(fetchType: .initail)
            })
            .disposed(by: bag)
        
        setOnlineUseCase
            .didChangeOnlineState
            .withUnretained(self)
            .subscribe(onNext: { vm, arg in
                let (groupId, memberId) = arg
                guard let index = vm.groupList?.firstIndex(where: { $0.groupId == groupId }),
                      var group = vm.groupList?[index] else { return }
                group.isOnline = !group.isOnline
                group.onlineCount = group.isOnline ? group.onlineCount + 1 : group.onlineCount - 1
                vm.groupList?[index] = group
                
                vm.didSuccessOnlineStateChange.onNext((index, true))
                vm.showMessage.onNext("\(group.groupName) 그룹을 \(group.isOnline ? "온" : "오프")라인으로 전환하였습니다.")
            })
            .disposed(by: bag)
        
        updateGroupInfoUseCase
            .didUpdateInfoWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList(fetchType: .initail)
            })
            .disposed(by: bag)
        
        withdrawGroupUseCase
            .didWithdrawGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                guard let index = vm.groupList?.firstIndex(where: { $0.groupId == id }) else { return }
                vm.groupList?.remove(at: index)
                vm.fetchMyGroupList(fetchType: .remove("성공적으로 탈퇴하였습니다."))
            })
            .disposed(by: bag)
        
        deleteGroupUseCase
            .didDeleteGroupWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                guard let index = vm.groupList?.firstIndex(where: { $0.groupId == id }) else { return }
                vm.groupList?.remove(at: index)
                vm.fetchMyGroupList(fetchType: .remove("그룹이 성공적으로 삭제되었습니다."))
            })
            .disposed(by: bag)
    }
    
    func setOnline(index: Int) {
        guard var group = self.groupList?[index] else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.setOnlineUseCase
                    .execute(token: token, groupId: group.groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUsecase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onFailure: { [weak self] _ in //이경우 다시 바꿔주고 바꾸기
                self?.didSuccessOnlineStateChange.onNext((index, false))
                self?.showMessage.onNext("\(group.groupName) 그룹 \(group.isOnline ? "온" : "오프")라인으로 전환에 실패하였습니다.")
            })
            .disposed(by: bag)
    }
    
    func fetchMyGroupList(fetchType: FetchType) {
        didStartFetching.onNext(())
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: { [weak self] in
            guard let self else { return }
            self.getTokenUseCase
                .execute()
                .flatMap { [weak self] token -> Single<[MyGroupSummary]> in
                    guard let self else {
                        throw DefaultError.noCapturedSelf
                    }
                    return self.fetchMyGroupListUseCase
                        .execute(token: token)
                }
                .handleRetry(
                    retryObservable: self.refreshTokenUsecase.execute(),
                    errorType: NetworkManagerError.tokenExpired
                )
                .subscribe(onSuccess: { [weak self] list in
                    print("here!")
                    self?.groupList = list
                    self?.didFetchGroupList.onNext((fetchType))
                }, onFailure: {
                    print($0)
                })
                .disposed(by: self.bag)
        })
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
}
