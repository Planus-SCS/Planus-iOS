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
        let vm = SearchViewModel()
        vm.setActions(actions: SearchViewModelActions(
            showSearchResultPage: self?.showSearchResultPage,
            showGroupIntroducePage: self?.showGroupIntroducePage
        ))
        let vc = SearchViewController(viewModel: vm)
        self?.navigationController.pushViewController(vc, animated: false)
    }

    lazy var showSearchResultPage: (String) -> Void = { [weak self] keyword in
        
    }
    
    lazy var showGroupIntroducePage: (String) -> Void = { [weak self] groupId in
        guard let self else { return }
        let groupIntroduceCoordinator = GroupIntroduceCoordinator(navigationController: self.navigationController)
        groupIntroduceCoordinator.finishDelegate = self
        self.childCoordinators.append(groupIntroduceCoordinator)
        groupIntroduceCoordinator.start()
    }
}

extension SearchCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
