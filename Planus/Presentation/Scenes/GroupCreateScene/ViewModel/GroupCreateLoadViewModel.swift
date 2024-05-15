//
//  GroupCreateLoadViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import Foundation
import RxSwift

final class GroupCreateLoadViewModel: ViewModelable {
    
    struct UseCases {
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let groupCreateUseCase: GroupCreateUseCase
    }
    
    struct Actions {
        let showCreatedGroupPage: ((Int) -> Void)?
        let backWithCreateFailure: ((Message) -> Void)?
    }
    
    struct Args {
        let groupCreationInfo: MyGroupCreationInfo
        let groupImage: ImageFile
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var groupCreate: MyGroupCreationInfo
    var groupImage: ImageFile
    
    struct Input {
        var viewDidLoad: Observable<Void>
    }
    
    struct Output {}
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.groupCreate = injectable.args.groupCreationInfo
        self.groupImage = injectable.args.groupImage
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.createGroup()
            })
            .disposed(by: bag)
        
        return Output()
    }
    
    func setGroupCreate(groupCreate: MyGroupCreationInfo, image: ImageFile) {
        self.groupCreate = groupCreate
        self.groupImage = image
    }
    
    func createGroup() {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                guard let self else { return nil }
                return self.useCases.groupCreateUseCase
                    .execute(
                        token: token,
                        groupCreate: self.groupCreate,
                        image: self.groupImage
                    )
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] groupId in
                self?.actions.showCreatedGroupPage?(groupId)
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.actions.backWithCreateFailure?(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}
