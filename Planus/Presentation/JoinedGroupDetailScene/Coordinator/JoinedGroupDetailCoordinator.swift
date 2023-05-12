//
//  JoinedGroupDetailCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit

class JoinedGroupDetailCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .joinedGroup
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(id: Int) {
        showGroupDetailPage(id)
    }
    
    lazy var showGroupDetailPage: (Int) -> Void = { [weak self] id in
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let fetchMyGroupDetailUseCase = DefaultFetchMyGroupDetailUseCase(myGroupRepository: myGroupRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let setOnlineStateUseCase = DefaultSetOnlineUseCase.shared
        let vm = JoinedGroupDetailViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            fetchMyGroupDetailUseCase: fetchMyGroupDetailUseCase,
            fetchImageUseCase: fetchImageUseCase,
            setOnlineUseCase: setOnlineStateUseCase
        )
        vm.setGroupId(id: id)
        vm.setActions(actions: JoinedGroupDetailViewModelActions(pop: self?.popCurrentPage))

        let vc = JoinedGroupDetailViewController(viewModel: vm)
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

extension JoinedGroupDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

