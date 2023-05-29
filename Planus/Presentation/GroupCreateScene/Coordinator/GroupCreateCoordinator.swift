//
//  GroupCreateCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupCreateCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .groupCreate
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showGroupCreatePage()
    }
    
    // 뷰모델 연결 시급
    lazy var showGroupCreatePage: () -> Void = { [weak self] in
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        
        let tokenRepository = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepository)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepository)
        let setTokenUseCase = DefaultSetTokenUseCase(tokenRepository: tokenRepository)
        let groupCreateUseCase = DefaultGroupCreateUseCase.shared
        let vm = GroupCreateViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            setTokenUseCase: setTokenUseCase,
            groupCreateUseCase: groupCreateUseCase
        )
        let vc = GroupCreateViewController(viewModel: vm)
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

extension GroupCreateCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

