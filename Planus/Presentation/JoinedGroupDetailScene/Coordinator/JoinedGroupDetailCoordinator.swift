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
    
    func start() {
        showGroupDetailPage()
    }
    
    lazy var showGroupDetailPage: () -> Void = { [weak self] in
        let vm = GroupIntroduceViewModel()
        vm.setActions(actions: GroupIntroduceViewModelActions(
            popCurrentPage: self?.popCurrentPage,
            didPop: self?.didPop)
        )
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

extension JoinedGroupDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

