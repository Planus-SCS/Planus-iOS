//
//  MyGroupMemberEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

final class MyGroupMemberEditViewModel: ViewModel {
    
    struct UseCases {
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase
        let fetchImageUseCase: FetchImageUseCase
        let memberKickOutUseCase: MemberKickOutUseCase
    }
    
    struct Actions {
        let pop: (() -> Void)?
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
    
    let groupId: Int
    var memberList: [MyGroupMemberProfile]?
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedResignButton: Observable<Int>
        var backBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didResignedAt: Observable<Int>
        var didFetchMemberList: Observable<Void?>
        var showMessage: Observable<Message>
    }
    
    var resignRequested = PublishSubject<Void>()
    var resignedAt = PublishSubject<Int>()
    var nowProcessingMemberId: [Int] = []
    var didFetchMemberList = BehaviorSubject<Void?>(value: nil)
    var showMessage = PublishSubject<Message>()
    
    init(
        useCase: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCase
        self.actions = injectable.actions
        
        self.groupId = injectable.args.groupId
    }
    
    func transform(input: Input) -> Output {
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMemberList()
            })
            .disposed(by: bag)
        
        input
            .didTappedResignButton
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.resignMember(index: index)
            })
            .disposed(by: bag)
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        return Output(
            didResignedAt: resignedAt.asObservable(),
            didFetchMemberList: didFetchMemberList.asObservable(),
            showMessage: showMessage.asObservable()
        )
    }
}

// MARK: - bind
private extension MyGroupMemberEditViewModel {
    func bindUseCase() {
        useCases
            .memberKickOutUseCase
            .didKickOutMemberAt
            .subscribe(onNext: { [weak self] (groupId, memberId) in
                guard let currentGroupId = self?.groupId,
                      groupId == currentGroupId,
                      let index = self?.memberList?.firstIndex(where: { $0.memberId == memberId }) else { return }
                self?.memberList?.remove(at: index)
                self?.resignedAt.onNext(index)
            })
            .disposed(by: bag)
    }
}

// MARK: - api
private extension MyGroupMemberEditViewModel {
    func resignMember(index: Int) {
        guard let memberId = memberList?[index].memberId,
              nowProcessingMemberId.filter({ $0 == memberId }).isEmpty else { return }
        nowProcessingMemberId.append(memberId)
        
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<Void>? in
                guard let self else { return nil }
                return self.useCases.memberKickOutUseCase
                    .execute(token: token, groupId: self.groupId, memberId: memberId)
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.nowProcessingMemberId.removeAll(where: { $0 == memberId})
                guard let index = self?.memberList?.firstIndex(where: { $0.memberId == memberId }) else { return }
                self?.memberList?.remove(at: index)
                self?.resignedAt.onNext(index)
            }, onFailure: { [weak self] error in
                self?.nowProcessingMemberId.removeAll(where: { $0 == memberId})
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let _, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
        
        memberList?.remove(at: index)
        resignedAt.onNext(index)
    }
    
    func fetchMemberList() {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<[MyGroupMemberProfile]>? in
                guard let self else { return nil }
                return self.useCases.fetchMyGroupMemberListUseCase
                    .execute(token: token, groupId: self.groupId)
            }
            .subscribe(onSuccess: { [weak self] list in
                self?.memberList = list
                self?.didFetchMemberList.onNext(())
            })
            .disposed(by: bag)
    }
}

// MARK: Image Fetcher
extension MyGroupMemberEditViewModel {
    func fetchImage(key: String) -> Single<Data> {
        useCases
            .fetchImageUseCase
            .execute(key: key)
    }
}
