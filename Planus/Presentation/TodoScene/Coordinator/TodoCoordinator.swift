//
//  TodoCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit

class TodoCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .todo
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showTodoPage()
    }
    
    lazy var showTodoPage: () -> Void = { [weak self] in
        let todoRepo = TestTodoDetailRepository(apiProvider: NetworkManager())
        let fetchTodoUseCase = DefaultReadTodoListUseCase(todoRepository: todoRepo)
        let createDailyCalendarUseCase = DefaultCreateDailyCalendarUseCase()
        let vm = TodoMainViewModel(fetchTodoListUseCase: fetchTodoUseCase, createDailyCalendarUseCase: createDailyCalendarUseCase)
        let vc = TodoMainViewController(viewModel: vm)
        
        self?.navigationController.pushViewController(vc, animated: false)
    }

    lazy var showDetailedTodoModal: () -> Void = { [weak self] in
        
    }
}

extension TodoCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
