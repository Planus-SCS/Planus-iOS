//
//  HomeCalendarCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit

class HomeCalendarCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .homeCalendar
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showHomeCalendarPage()
    }
    
    lazy var showHomeCalendarPage: () -> Void = { [weak self] in
        
        let todoRepository = TestTodoRepository()
        
        let createMonthlyCalendarUseCase = DefaultCreateMonthlyCalendarUseCase()
        let readTodoListUseCase = DefaultReadTodoListUseCase(todoRepository: todoRepository)
        let dateFormatYYYYMMUseCase = DefaultDateFormatYYYYMMUseCase()
        let createTodoUseCase = DefaultCreateTodoUseCase.shared
        let updateTodoUseCase = DefaultUpdateTodoUseCase.shared
        let deleteTodoUseCase = DefaultDeleteTodoUseCase.shared

        let vm = HomeCalendarViewModel(
            createMonthlyCalendarUseCase: createMonthlyCalendarUseCase,
            readTodoListUseCase: readTodoListUseCase,
            createTodoUseCase: createTodoUseCase,
            updateTodoUseCase: updateTodoUseCase,
            deleteTodoUseCase: deleteTodoUseCase,
            dateFormatYYYYMMUseCase: dateFormatYYYYMMUseCase
        )
        
        let vc = HomeCalendarViewController(viewModel: vm)
        self?.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showTodoModal: () -> Void = { [weak self] in
    }
    
    lazy var showMyPage: () -> Void = {
        
    }
}

extension HomeCalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
