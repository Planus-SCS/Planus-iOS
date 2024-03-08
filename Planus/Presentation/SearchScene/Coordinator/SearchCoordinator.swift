//
//  SearchCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit

class SearchCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .search
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showInitialSearchPage()
    }
    
    lazy var showInitialSearchPage: () -> Void = { [weak self] in
        let vm = SearchHomeViewModel(
            getTokenUseCase: DefaultGetTokenUseCase(tokenRepository: DefaultTokenRepository(apiProvider: NetworkManager(), keyValueStorage: KeyChainManager())), refreshTokenUseCase: DefaultRefreshTokenUseCase(tokenRepository: DefaultTokenRepository(apiProvider: NetworkManager(), keyValueStorage: KeyChainManager())),
            fetchSearchHomeUseCase: DefaultFetchSearchHomeUseCase(groupRepository: DefaultGroupRepository(apiProvider: NetworkManager())), fetchImageUseCase: DefaultFetchImageUseCase(imageRepository: DefaultImageRepository.shared))
        vm.setActions(actions: SearchHomeViewModelActions(
            showSearchResultPage: self?.showSearchResultPage,
            showGroupIntroducePage: self?.showGroupIntroducePage,
            showGroupCreatePage: self?.showGroupCreatePage
        ))
        let vc = SearchHomeViewController(viewModel: vm)
        self?.navigationController.pushViewController(vc, animated: false)
    }

    lazy var showSearchResultPage: () -> Void = { [weak self] in
        let vm = SearchResultViewModel(
            recentQueryRepository: DefaultRecentQueryRepository(),
            getTokenUseCase: DefaultGetTokenUseCase(tokenRepository: DefaultTokenRepository(apiProvider: NetworkManager(), keyValueStorage: KeyChainManager())), refreshTokenUseCase: DefaultRefreshTokenUseCase(tokenRepository: DefaultTokenRepository(apiProvider: NetworkManager(), keyValueStorage: KeyChainManager())),
            fetchSearchResultUseCase: DefaultFetchSearchResultUseCase(groupRepository: DefaultGroupRepository(apiProvider: NetworkManager())), fetchImageUseCase: DefaultFetchImageUseCase(imageRepository: DefaultImageRepository.shared)
        )

        vm.setActions(actions: SearchResultViewModelActions(
            pop: self?.popCurrentPage,
            showGroupIntroducePage: self?.showGroupIntroducePage,
            showGroupCreatePage: self?.showGroupCreatePage
        ))
        
        let vc = SearchResultViewController(viewModel: vm)
        self?.navigationController.pushViewController(vc, animated: false)
    }
    
    lazy var showGroupIntroducePage: (Int) -> Void = { [weak self] groupId in
        guard let self else { return }
        let groupIntroduceCoordinator = GroupIntroduceCoordinator(navigationController: self.navigationController)
        groupIntroduceCoordinator.finishDelegate = self
        self.childCoordinators.append(groupIntroduceCoordinator)
        groupIntroduceCoordinator.start(id: groupId)
    }
    
    lazy var showGroupCreatePage: () -> Void = { [weak self] in
        guard let self else { return }
        let groupCreateCoordinator = GroupCreateCoordinator(navigationController: self.navigationController)
        groupCreateCoordinator.finishDelegate = self
        self.childCoordinators.append(groupCreateCoordinator)
        groupCreateCoordinator.start()
    }
    
    lazy var popCurrentPage: () -> Void = { [weak self] in
        self?.navigationController.popViewController(animated: true)
    }
}

extension SearchCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
