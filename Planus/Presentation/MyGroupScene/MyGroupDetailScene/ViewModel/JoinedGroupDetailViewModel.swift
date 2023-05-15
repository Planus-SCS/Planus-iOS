//
//  JoinedGroupDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import Foundation
import RxSwift

struct JoinedGroupDetailViewModelActions {
    var pop: (() -> Void)?
}

class JoinedGroupDetailViewModel {
    var bag = DisposeBag()
    var actions: JoinedGroupDetailViewModelActions?
    
    var groupId: Int?
    var groupTitle: String?
    var groupImageUrl: String?
    var tag: [String]?
    var memberCount: Int?
    var limitCount: Int?
    var leaderName: String?
    var isLeader: Bool?
    
    var groupNotice = BehaviorSubject<String?>(value: nil)
    var onlineCount = BehaviorSubject<Int?>(value: nil)
    
    var isOnline = BehaviorSubject<Bool?>(value: nil)
    var groupDetailFetched = BehaviorSubject<Void?>(value: nil)
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var onlineStateChanged: Observable<Bool>
    }
    
    struct Output {
        var didFetchGroupDetail: Observable<Void?>
        var isOnline: Observable<Bool?>
        var onlineCountChanged: Observable<Int?>
        var noticeFetched: Observable<String?>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var fetchMyGroupDetailUseCase: FetchMyGroupDetailUseCase
    var fetchImageUseCase: FetchImageUseCase
    var setOnlineUseCase: SetOnlineUseCase
    var updateNoticeUseCase: UpdateNoticeUseCase

    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchMyGroupDetailUseCase: FetchMyGroupDetailUseCase,
        fetchImageUseCase: FetchImageUseCase,
        setOnlineUseCase: SetOnlineUseCase,
        updateNoticeUseCase: UpdateNoticeUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchMyGroupDetailUseCase = fetchMyGroupDetailUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.setOnlineUseCase = setOnlineUseCase
        self.updateNoticeUseCase = updateNoticeUseCase
    }
    
    func setGroupId(id: Int) {
        self.groupId = id
    }
    
    func setActions(actions: JoinedGroupDetailViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let groupId = vm.groupId else { return }
                vm.fetchGroupDetail(groupId: groupId)
            })
            .disposed(by: bag)
        
        input
            .onlineStateChanged
            .withUnretained(self)
            .subscribe(onNext: { vm, isOnline in
                guard let currentState = try? vm.isOnline.value(),
                   currentState != isOnline else { return }
                vm.setOnlineState(isOnline: isOnline)
            })
            .disposed(by: bag)
        
        return Output(
            didFetchGroupDetail: groupDetailFetched.asObservable(),
            isOnline: isOnline.asObservable(),
            onlineCountChanged: onlineCount.asObservable(),
            noticeFetched: groupNotice.asObservable()
        )
    }
    
    func fetchGroupDetail(groupId: Int) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<MyGroupDetail> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupDetailUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] detail in
                self?.isLeader = detail.isLeader
                self?.groupTitle = detail.groupName
                self?.groupImageUrl = detail.groupImageUrl
                self?.tag = detail.groupTags.map { $0.name }
                self?.memberCount = detail.memberCount
                self?.limitCount = detail.limitCount
                self?.onlineCount.onNext(detail.onlineCount)
                self?.leaderName = detail.leaderName
                self?.groupNotice.onNext(detail.notice)
                self?.isOnline.onNext(detail.isOnline)
                self?.groupDetailFetched.onNext(())
            })
            .disposed(by: bag) //.map { "#\($0.name)" }.joined(separator: " ")
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
    
    func bindUseCase() {
        setOnlineUseCase
            .didChangeOnlineState
            .withUnretained(self)
            .subscribe(onNext: { vm, groupId in
                if groupId == vm.groupId {
                    guard let exValue = try? vm.isOnline.value(),
                          let onlineCount = try? vm.onlineCount.value() else { return }
                    let newValue = !exValue
                    vm.isOnline.onNext(newValue)
                    vm.onlineCount.onNext(newValue ? (onlineCount + 1) : (onlineCount - 1))
                }
            })
            .disposed(by: bag)
        
        updateNoticeUseCase
            .didUpdateNotice
            .withUnretained(self)
            .subscribe(onNext: { vm, groupNotice in
                guard let id = vm.groupId,
                      id == groupNotice.groupId else { return }
                vm.groupNotice.onNext(groupNotice.notice)
            })
            .disposed(by: bag)
    }
    
    func setOnlineState(isOnline: Bool) {
        guard let groupId else { return }
        
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
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onError: { [weak self] _ in
                self?.isOnline.onNext(try? self?.isOnline.value())
            })
            .disposed(by: bag)
    }
    
}
