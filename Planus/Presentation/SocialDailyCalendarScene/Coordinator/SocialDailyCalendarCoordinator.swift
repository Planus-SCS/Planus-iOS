//
//  SocialDailyCalendarCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import UIKit
import RxSwift

class SocialDailyCalendarCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .socialDailyCalendar
    
    var modalNavigationVC: UINavigationController?
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(args: SocialDailyCalendarViewModel.Args) {
        showDailyCalendarPage(args)
    }
    
    lazy var showDailyCalendarPage: (SocialDailyCalendarViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let viewController = self.dependency.injector.resolve(
            SocialDailyCalendarViewController.self,
            argument: SocialDailyCalendarViewModel.Injectable(
                actions: .init(
                    showSocialTodoDetail: showSocialTodoDetail,
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
    
    lazy var showSocialTodoDetail: () -> Void = { [weak self] in
//        guard let self,
//              let modalNavigationVC else { return }
//
//        let coordinator = TodoDetailCoordinator(
//            dependency: TodoDetailCoordinator.Dependency(
//                navigationController: modalNavigationVC,
//                injector: self.dependency.injector,
//                closeHandler: closeHandler
//            )
//        )
//        coordinator.finishDelegate = self
//        self.childCoordinators.append(coordinator)
//        coordinator.start(type: .memberTodo, args: args)
    }
    
    lazy var finishScene: (() -> Void)? = { [weak self] in
        self?.finish()
    }

}

extension SocialDailyCalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
