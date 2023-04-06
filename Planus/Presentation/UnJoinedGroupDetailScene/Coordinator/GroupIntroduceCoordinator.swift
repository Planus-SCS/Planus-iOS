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
    
    func start() {
        showGroupIntroducePage()
    }
    
    lazy var showGroupIntroducePage: () -> Void = { [weak self] in
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

extension GroupIntroduceCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
