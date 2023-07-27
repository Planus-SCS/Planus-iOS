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
    var showGroupDetailPage = PublishSubject<Int>()
    var isJoinableGroup = BehaviorSubject<Bool?>(value: nil)
    var applyCompleted = PublishSubject<Void>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedJoinBtn: Observable<Void>
        var didTappedBackBtn: Observable<Void>
    }
    
    struct Output {
        var didGroupInfoFetched: Observable<Void?>
        var didGroupMemberFetched: Observable<Void?>
        var isJoinableGroup: Observable<Bool?>
        var didCompleteApply: Observable<Void>
        var showGroupDetailPage: Observable<Int>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchUnJoinedGroupUseCase: FetchUnJoinedGroupUseCase
    var fetchMemberListUseCase: FetchMemberListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var applyGroupJoinUseCase: ApplyGroupJoinUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchUnjoinedGroupUseCase: FetchUnJoinedGroupUseCase,
        fetchMemberListUseCase: FetchMemberListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        applyGroupJoinUseCase: ApplyGroupJoinUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.setTokenUseCase = setTokenUseCase
        self.fetchUnJoinedGroupUseCase = fetchUnjoinedGroupUseCase
        self.fetchMemberListUseCase = fetchMemberListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.applyGroupJoinUseCase = applyGroupJoinUseCase
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
                guard let isJoined = try? vm.isJoinableGroup.value(),
                      let groupId = vm.groupId else { return }
                if isJoined {
                    vm.showGroupDetailPage.onNext((groupId))
                } else {
                    vm.requestJoinGroup()
                }
                
            })
            .disposed(by: bag)
        
        input
            .didTappedBackBtn
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vm, _ in
                vm.actions?.popCurrentPage?()
            })
            .disposed(by: bag)
        
        return Output(
            didGroupInfoFetched: didGroupInfoFetched.asObservable(),
            didGroupMemberFetched: didGroupMemberFetched.asObservable(),
            isJoinableGroup: isJoinableGroup.asObservable(),
            didCompleteApply: applyCompleted.asObservable(),
            showGroupDetailPage: showGroupDetailPage.asObservable()
        )
    }
    
    func fetchGroupInfo(id: Int) {
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<UnJoinedGroupDetail> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchUnJoinedGroupUseCase
                    .execute(token: token, id: id)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] groupDetail in
                self?.groupTitle = groupDetail.name
                self?.tag = groupDetail.groupTags.map { "#\($0.name)" }.joined(separator: " ")
                self?.memberCount = "\(groupDetail.memberCount)/\(groupDetail.limitCount)"
                self?.captin = groupDetail.leaderName
                self?.notice = groupDetail.notice
                self?.groupImageUrl = groupDetail.groupImageUrl
                self?.didGroupInfoFetched.onNext(())
                self?.isJoinableGroup.onNext(groupDetail.isJoined)
            })
            .disposed(by: bag)
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Member]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMemberListUseCase
                    .execute(token: token, groupId: id)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.memberList = list
                self?.didGroupMemberFetched.onNext(())
            })
            .disposed(by: bag)
    }
    
    func requestJoinGroup() {
        guard let groupId = groupId else { return }

        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.applyGroupJoinUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.actions?.popCurrentPage?()
            }, onFailure: { [weak self] error in
                
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        return fetchImageUseCase
            .execute(key: key)
    }
}
