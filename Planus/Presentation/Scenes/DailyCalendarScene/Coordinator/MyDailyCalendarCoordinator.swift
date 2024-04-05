//
//  MyDailyCalendarCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

final class MyDailyCalendarCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .myDailyCalendar
    
    var modalNavigationVC: UINavigationController?
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(args: MyDailyCalendarViewModel.Args) {
        showDailyCalendarPage(args)
    }
    
    lazy var showDailyCalendarPage: (MyDailyCalendarViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            MyDailyCalendarViewModel.self,
            injectable: MyDailyCalendarViewModel.Injectable(
                actions: .init(
                    showTodoDetailPage: showTodoDetailPage,
                    finishScene: finishScene
                ),
                args: args
            )
        )
        
        let vc = DailyCalendarViewController(viewModel: vm)
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        dependency.navigationController.present(nav, animated: true)
        
        self.modalNavigationVC = nav
    }
    
    lazy var showTodoDetailPage: (MyTodoDetailViewModel.Args, (() -> Void)?) -> Void = { [weak self] args, closeHandler in
        guard let self,
              let modalNavigationVC else { return }

        let coordinator = MyTodoDetailCoordinator(
            dependency: MyTodoDetailCoordinator.Dependency(
                navigationController: modalNavigationVC,
                injector: self.dependency.injector,
                closeHandler: closeHandler
            )
        )
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(args: args)
    }
    
    lazy var finishScene: (() -> Void)? = { [weak self] in
        self?.finish()
    }

}

extension MyDailyCalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
