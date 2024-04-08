//
//  MyGroupListViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import Foundation
import RxSwift

final class MyGroupListViewModel: ViewModel {
    
    struct UseCases {
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let fetchMyGroupListUseCase: FetchMyGroupListUseCase
        let fetchImageUseCase: FetchImageUseCase
        let groupCreateUseCase: GroupCreateUseCase
        let setOnlineUseCase: SetOnlineUseCase
        let updateGroupInfoUseCase: UpdateGroupInfoUseCase
        let withdrawGroupUseCase: WithdrawGroupUseCase
        let deleteGroupUseCase: DeleteGroupUseCase
    }
    
    struct Actions {
        let showGroupDetailPage: ((Int) -> Void)?
        let showNotificationPage: (() -> Void)?
    }
    
    struct Args {}
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var groupList: [MyGroupSummary]?
    
    var didStartFetching = BehaviorSubject<Void?>(value: nil)
    var didFetchGroupList = BehaviorSubject<FetchType?>(value: nil)
    var needReloadItemAt = PublishSubject<Int>()
    var didSuccessOnlineStateChange = PublishSubject<(Int, Bool)>() //index, isSuccess
    var showMessage = PublishSubject<Message>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var tappedAt: Observable<Int>
        var becameOnlineStateAt: Observable<Int>
        var becameOfflineStateAt: Observable<Int>
        var refreshRequired: Observable<Void>
        var notificationBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didStartFetching: Observable<Void?>
        var didFetchJoinedGroup: Observable<FetchType?>
        var needReloadItemAt: Observable<Int>
        var showMessage: Observable<Message>
        var didSuccessOnlineStateChange: Observable<(Int, Bool)>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
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
                vm.actions.showGroupDetailPage?(id)
            })
            .disposed(by: bag)
        
        input
            .notificationBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.showNotificationPage?()
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
        useCases
            .groupCreateUseCase
            .didCreateGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList(fetchType: .initail)
            })
            .disposed(by: bag)
        
        useCases
            .setOnlineUseCase
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
                vm.showMessage.onNext(Message(text: "\(group.groupName) 그룹을 \(group.isOnline ? "온" : "오프")라인으로 전환하였습니다.", state: .normal))
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupInfoUseCase
            .didUpdateInfoWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMyGroupList(fetchType: .initail)
            })
            .disposed(by: bag)
        
        useCases
            .withdrawGroupUseCase
            .didWithdrawGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                guard let index = vm.groupList?.firstIndex(where: { $0.groupId == id }) else { return }
                vm.groupList?.remove(at: index)
                vm.fetchMyGroupList(fetchType: .remove("성공적으로 탈퇴하였습니다."))
            })
            .disposed(by: bag)
        
        useCases
            .deleteGroupUseCase
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
        
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.setOnlineUseCase
                    .execute(token: token, groupId: group.groupId)
            }
            .subscribe(onFailure: { [weak self] _ in
                self?.didSuccessOnlineStateChange.onNext((index, false))
                self?.showMessage.onNext(Message(text: "\(group.groupName) 그룹 \(group.isOnline ? "온" : "오프")라인으로 전환에 실패하였습니다.", state: .normal))
            })
            .disposed(by: bag)
    }
    
    func fetchMyGroupList(fetchType: FetchType) {
        didStartFetching.onNext(())
        
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchMyGroupListUseCase
                    .execute(token: token)
            }
            .subscribe(onSuccess: { [weak self] list in
                self?.groupList = list
                self?.didFetchGroupList.onNext((fetchType))
            }, onFailure: { [weak self] _ in
                self?.showMessage.onNext(Message(text: "얘기치 못한 이유로 로딩을 실패했어요 😭", state: .warning))
            })
            .disposed(by: self.bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        useCases
            .fetchImageUseCase
            .execute(key: key)
    }
}
