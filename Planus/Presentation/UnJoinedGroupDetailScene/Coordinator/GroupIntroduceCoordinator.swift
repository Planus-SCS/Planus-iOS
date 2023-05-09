//
//  GroupIntroduceCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupIntroduceCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .groupIntroduce
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(id: Int) {
        showGroupIntroducePage(id)
    }
    
    lazy var showGroupIntroducePage: (Int) -> Void = { [weak self] id in
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let categoryRepo = DefaultCategoryRepository(apiProvider: api)
        let profileRepo = DefaultProfileRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let groupRepo = DefaultGroupRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let setTokenUseCase = DefaultSetTokenUseCase(tokenRepository: tokenRepo)
        let fetchUnjoinedGroupUseCase = DefaultFetchUnJoinedGroupUseCase(groupRepository: groupRepo)
        let fetchMemberListUseCase = DefaultFetchMemberListUseCase(groupRepository: groupRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let vm = GroupIntroduceViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            setTokenUseCase: setTokenUseCase,
            fetchUnjoinedGroupUseCase: fetchUnjoinedGroupUseCase,
            fetchMemberListUseCase: fetchMemberListUseCase,
            fetchImageUseCase: fetchImageUseCase
        )
        vm.setActions(actions: GroupIntroduceViewModelActions(
            popCurrentPage: self?.popCurrentPage,
            didPop: self?.didPop)
        )
        vm.setGroupId(id: 3)
        let vc = GroupIntroduceViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true

        self?.navigationController.pushViewController(vc, animated: true)
    }

    lazy var popCurrentPage: () -> Void = { [weak self] in
        self?.navigationController.popViewController(animated: true)
        self?.didPop()
    }
    
    lazy var didPop: () -> Void = { [weak self] in
        guard let self else { return }
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension GroupIntroduceCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
