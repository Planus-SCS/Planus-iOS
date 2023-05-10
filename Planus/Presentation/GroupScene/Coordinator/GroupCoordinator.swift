//
//  GroupCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit

class GroupCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .group

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showGroupListPage()
    }
    
    lazy var showGroupListPage: () -> Void = { [weak self] in
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        
        let tokenRepository = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepository)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepository)
        let setTokenUseCase = DefaultSetTokenUseCase(tokenRepository: tokenRepository)
        let fetchMyGroupUseCase = DefaultFetchMyGroupListUseCase(myGroupRepository: myGroupRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let groupCreateUseCase = DefaultGroupCreateUseCase.shared
        let vm = GroupListViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUsecase: refreshTokenUseCase,
            setTokenUseCase: setTokenUseCase,
            fetchMyGroupListUseCase: fetchMyGroupUseCase,
            fetchImageUseCase: fetchImageUseCase,
            groupCreateUseCase: groupCreateUseCase
        )
        
        vm.setActions(actions: GroupListViewModelActions(showJoinedGroupDetail: self?.showGroupDetailPage))
        let vc = GroupListViewController(viewModel: vm)
        self?.navigationController.pushViewController(vc, animated: true)
    }

    lazy var showGroupDetailPage: (Int) -> Void = { [weak self] id in
        guard let self else { return }
        let coordinator = JoinedGroupDetailCoordinator(navigationController: self.navigationController)
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(id: id)
    }
}

extension GroupCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

