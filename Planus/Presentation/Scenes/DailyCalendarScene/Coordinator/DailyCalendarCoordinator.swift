//
//  DailyCalendarCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

final class DailyCalendarCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .dailyCalendar
    
    var modalNavigationVC: UINavigationController?
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(args: DailyCalendarViewModel.Args) {
        showDailyCalendarPage(args)
    }
    
    lazy var showDailyCalendarPage: (DailyCalendarViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let viewController = self.dependency.injector.resolve(
            DailyCalendarViewController.self,
            argument: DailyCalendarViewModel.Injectable(
                actions: .init(
                    showTodoDetailPage: showTodoDetailPage,
                    finishScene: finishScene
                ),
                args: args
            )
        )
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        dependency.navigationController.present(nav, animated: true)
        
        self.modalNavigationVC = nav
    }
    
    lazy var showTodoDetailPage: (MemberTodoDetailViewModel.Args, (() -> Void)?) -> Void = { [weak self] args, closeHandler in
        guard let self,
              let modalNavigationVC else { return }

        let coordinator = TodoDetailCoordinator(
            dependency: TodoDetailCoordinator.Dependency(
                navigationController: modalNavigationVC,
                injector: self.dependency.injector,
                closeHandler: closeHandler
            )
        )
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.startMember(args: args)
    }
    
    lazy var finishScene: (() -> Void)? = { [weak self] in
        self?.finish()
    }

}

extension DailyCalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
