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

enum GroupJoinableState {
    case isJoined
    case notJoined
    case full
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
    var isJoinableGroup = BehaviorSubject<GroupJoinableState?>(value: nil)
    var applyCompleted = PublishSubject<Void>()
    var showMessage = PublishSubject<Message>()
    var showShareMenu = PublishSubject<String?>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedJoinBtn: Observable<Void>
        var didTappedBackBtn: Observable<Void>
        var shareBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didGroupInfoFetched: Observable<Void?>
        var didGroupMemberFetched: Observable<Void?>
        var isJoinableGroup: Observable<GroupJoinableState?>
        var didCompleteApply: Observable<Void>
        var showGroupDetailPage: Observable<Int>
        var showMessage: Observable<Message>
        var showShareMenu: Observable<String?>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchUnJoinedGroupUseCase: FetchUnJoinedGroupUseCase
    var fetchMemberListUseCase: FetchMemberListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var applyGroupJoinUseCase: ApplyGroupJoinUseCase
    var generateGroupLinkUseCase: GenerateGroupLinkUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchUnjoinedGroupUseCase: FetchUnJoinedGroupUseCase,
        fetchMemberListUseCase: FetchMemberListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        applyGroupJoinUseCase: ApplyGroupJoinUseCase,
        generateGroupLinkUseCase: GenerateGroupLinkUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.setTokenUseCase = setTokenUseCase
        self.fetchUnJoinedGroupUseCase = fetchUnjoinedGroupUseCase
        self.fetchMemberListUseCase = fetchMemberListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.applyGroupJoinUseCase = applyGroupJoinUseCase
        self.generateGroupLinkUseCase = generateGroupLinkUseCase
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    vm.fetchGroupInfo(id: id)
                })
            })
            .disposed(by: bag)
        
        input
            .didTappedJoinBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let isJoined = try? vm.isJoinableGroup.value(),
                      let groupId = vm.groupId else { return }
                
                switch isJoined {
                case .isJoined:
                    vm.showGroupDetailPage.onNext((groupId))
                case .notJoined:
                    vm.requestJoinGroup()
                default:
                    break
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
        
        input
            .shareBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                let urlString = vm.generateShareLink()
                vm.showShareMenu.onNext(urlString)
            })
            .disposed(by: bag)
        
        return Output(
            didGroupInfoFetched: didGroupInfoFetched.asObservable(),
            didGroupMemberFetched: didGroupMemberFetched.asObservable(),
            isJoinableGroup: isJoinableGroup.asObservable(),
            didCompleteApply: applyCompleted.asObservable(),
            showGroupDetailPage: showGroupDetailPage.asObservable(),
            showMessage: showMessage.asObservable(),
            showShareMenu: showShareMenu.asObservable()
        )
    }
    
    func generateShareLink() -> String? {
        guard let groupId = groupId else { return nil }
        return generateGroupLinkUseCase.execute(groupId: groupId)
    }
    
    func fetchGroupInfo(id: Int) {
        
        let fetchGroupDetail = getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<GroupDetail> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchUnJoinedGroupUseCase
                    .execute(token: token, id: id)
            }
        
        let fetchGroupMember = getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Member]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMemberListUseCase
                    .execute(token: token, groupId: id)
            }
        
        Single.zip(
            fetchGroupDetail,
            fetchGroupMember
        )
        .handleRetry( //특정 놈이 에러 방출 시 전체에 영향감
            retryObservable: refreshTokenUseCase.execute(),
            errorType: NetworkManagerError.tokenExpired
        )
        .subscribe(onSuccess: { [weak self] (groupDetail, memberList) in
            self?.groupTitle = groupDetail.name
            self?.tag = groupDetail.groupTags.map { "#\($0.name)" }.joined(separator: " ")
            self?.memberCount = "\(groupDetail.memberCount)/\(groupDetail.limitCount)"
            self?.captin = groupDetail.leaderName
            self?.notice = groupDetail.notice
            self?.groupImageUrl = groupDetail.groupImageUrl
            self?.didGroupInfoFetched.onNext(())
            self?.isJoinableGroup.onNext(groupDetail.isJoined ? .isJoined : (groupDetail.memberCount >= groupDetail.limitCount) ? .full : .notJoined)
            
            self?.memberList = memberList
            self?.didGroupMemberFetched.onNext(())
        }, onFailure: { [weak self] error in
            self?.didGroupInfoFetched.onError(error)
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
                self?.showMessage.onNext(Message(text: "가입을 요청하였습니다.", state: .normal))
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        return fetchImageUseCase
            .execute(key: key)
    }
}
