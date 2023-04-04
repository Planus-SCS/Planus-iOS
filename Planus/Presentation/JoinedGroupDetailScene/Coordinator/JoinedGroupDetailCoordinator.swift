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
    
    func start(id: String) {
        showGroupDetailPage(id)
    }
    
    lazy var showGroupDetailPage: (String) -> Void = { [weak self] id in
        let repo = TestTodoRepository()
        let c = DefaultCreateMonthlyCalendarUseCase()
        let f = DefaultFetchTodoListUseCase(todoRepository: repo)
        let vm = JoinedGroupDetailViewModel(createMonthlyCalendarUseCase: c, fetchTodoListUseCase: f)
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

