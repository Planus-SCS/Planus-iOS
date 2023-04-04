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
        let vm = GroupListViewModel()
        vm.setActions(actions: GroupListViewModelActions(showJoinedGroupDetail: self?.showGroupDetailPage))
        let vc = GroupListViewController(viewModel: vm)
        self?.navigationController.pushViewController(vc, animated: true)
    }

    lazy var showGroupDetailPage: (String) -> Void = { [weak self] id in
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

