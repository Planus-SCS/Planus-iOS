//
//  SearchCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit

class SearchCoordinator: Coordinator {
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .search
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start() {
        showInitialSearchPage()
    }
    
    lazy var showInitialSearchPage: () -> Void = { [weak self] in
        guard let self else { return }
        
        let vc = dependency.injector.resolve(
            SearchHomeViewController.self,
            argument: SearchHomeViewModel.Injectable(
                actions: .init(
                    showSearchResultPage: self.showSearchResultPage,
                    showGroupIntroducePage: self.showGroupIntroducePage,
                    showGroupCreatePage: self.showGroupCreatePage
                ),
                args: .init()
            )
        )
        
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }

    lazy var showSearchResultPage: () -> Void = { [weak self] in
        guard let self else { return }
        
        let vc = dependency.injector.resolve(
            SearchResultViewController.self,
            argument: SearchResultViewModel.Injectable(
                actions: .init(
                    pop: self.popCurrentPage,
                    showGroupIntroducePage: self.showGroupIntroducePage,
                    showGroupCreatePage: self.showGroupCreatePage
                ),
                args: .init()
            )
        )

        self.dependency.navigationController.pushViewController(vc, animated: false)
    }
    
    lazy var showGroupIntroducePage: (Int) -> Void = { [weak self] groupId in
        guard let self else { return }
        let groupIntroduceCoordinator = GroupIntroduceCoordinator(
            dependency: GroupIntroduceCoordinator.Dependency(
                navigationController: self.dependency.navigationController,
                injector: self.dependency.injector
            )
        )
        groupIntroduceCoordinator.finishDelegate = self
        self.childCoordinators.append(groupIntroduceCoordinator)
        groupIntroduceCoordinator.start(id: groupId)
    }
    
    lazy var showGroupCreatePage: () -> Void = { [weak self] in
        guard let self else { return }
        let groupCreateCoordinator = GroupCreateCoordinator(
            dependency: GroupCreateCoordinator.Dependency(
                navigationController: dependency.navigationController,
                injector: dependency.injector
            )
        )
        groupCreateCoordinator.finishDelegate = self
        self.childCoordinators.append(groupCreateCoordinator)
        groupCreateCoordinator.start()
    }
    
    lazy var popCurrentPage: () -> Void = { [weak self] in
        self?.dependency.navigationController.popViewController(animated: true)
    }
}

extension SearchCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
