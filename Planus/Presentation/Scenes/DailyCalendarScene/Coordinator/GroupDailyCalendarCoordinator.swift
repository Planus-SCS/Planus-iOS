//
//  GroupDailyCalendarCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import UIKit
import RxSwift

final class GroupDailyCalendarCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .groupDailyCalendar
    
    var modalNavigationVC: UINavigationController?
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(args: GroupDailyCalendarViewModel.Args) {
        showDailyCalendarPage(args)
    }
    
    lazy var showDailyCalendarPage: (GroupDailyCalendarViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            GroupDailyCalendarViewModel.self,
            injectable: GroupDailyCalendarViewModel.Injectable(
                actions: .init(
                    showTodoDetail: showTodoDetailPage,
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
    
    lazy var showTodoDetailPage: (GroupTodoDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self,
              let modalNavigationVC else { return }

        let coordinator = GroupTodoDetailCoordinator(
            dependency: GroupTodoDetailCoordinator.Dependency(
                navigationController: modalNavigationVC,
                injector: self.dependency.injector
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

extension GroupDailyCalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
