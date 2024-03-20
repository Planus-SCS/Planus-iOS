//
//  GroupIntroduceViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import Foundation
import RxSwift

enum GroupJoinableState {
    case isJoined
    case notJoined
    case full
}

class GroupIntroduceViewModel: ViewModel {
    
    struct UseCases {
        let getTokenUseCase: GetTokenUseCase
        let refreshTokenUseCase: RefreshTokenUseCase
        let setTokenUseCase: SetTokenUseCase
        let fetchUnJoinedGroupUseCase: FetchUnJoinedGroupUseCase
        let fetchMemberListUseCase: FetchMemberListUseCase
        let fetchImageUseCase: FetchImageUseCase
        let applyGroupJoinUseCase: ApplyGroupJoinUseCase
        let generateGroupLinkUseCase: GenerateGroupLinkUseCase
    }
    
    struct Actions {
        var showMyGroupDetailPage: ((Int) -> Void)?
        var pop: (() -> Void)?
        var finishScene: (() -> Void)?
    }
    
    struct Args {
        let groupId: Int
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var groupId: Int

    var groupTitle: String?
    var tag: String?
    var memberCount: String?
    var captin: String?
    var notice: String?
    var groupImageUrl: String?
    var memberList: [Member]?
    
    var didGroupInfoFetched = BehaviorSubject<Void?>(value: nil)
    var didGroupMemberFetched = BehaviorSubject<Void?>(value: nil)
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
        var showMessage: Observable<Message>
        var showShareMenu: Observable<String?>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.groupId = injectable.args.groupId
    }
    
    func transform(input: Input) -> Output {
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    vm.fetchGroupInfo(id: vm.groupId)
                })
            })
            .disposed(by: bag)
        
        input
            .didTappedJoinBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let isJoined = try? vm.isJoinableGroup.value() else { return }
                
                switch isJoined {
                case .isJoined:
                    vm.actions.showMyGroupDetailPage?(vm.groupId)
                case .notJoined:
                    vm.requestJoinGroup()
                default:
                    break
                }                
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
            showMessage: showMessage.asObservable(),
            showShareMenu: showShareMenu.asObservable()
        )
    }
    
    func generateShareLink() -> String? {
        return useCases.generateGroupLinkUseCase.execute(groupId: groupId)
    }
    
    func fetchGroupInfo(id: Int) {
        
        let fetchGroupDetail = useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<GroupDetail> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.fetchUnJoinedGroupUseCase
                    .execute(token: token, id: id)
            }
        
        let fetchGroupMember = useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Member]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.fetchMemberListUseCase
                    .execute(token: token, groupId: id)
            }
        
        Single.zip(
            fetchGroupDetail,
            fetchGroupMember
        )
        .handleRetry(
            retryObservable: useCases.refreshTokenUseCase.execute(),
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
        
        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.applyGroupJoinUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
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
        return useCases.fetchImageUseCase
            .execute(key: key)
    }
}