//
//  HomeCalendarCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit
import RxSwift

class HomeCalendarCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .homeCalendar
    var homeTapReselected = PublishSubject<Void>()
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start() {
        showHomeCalendarPage()
    }
    
    lazy var showHomeCalendarPage: () -> Void = { [weak self] in
        guard let self else { return }
        let vc = self.dependency.injector.resolve(
            HomeCalendarViewController.self,
            argument: HomeCalendarViewModel.Injectable(
                actions: .init(
                    showDailyCalendarPage: self.showDailyCalendarPage,
                    showCreatePeriodTodoPage: self.showTodoDetailPage,
                    showMyPage: self.showMyPage
                ),
                args: .init()
            )
        )
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showDailyCalendarPage: (TodoDailyViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        
        let coordinator = TodoDailyCoordinator(
            dependency:TodoDailyCoordinator.Dependency(
                navigationController: self.dependency.navigationController,
                injector: self.dependency.injector
            )
        )
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(args: args)
    }
    
    lazy var showTodoDetailPage: (TodoDetailViewModelArgs, (() -> Void)?) -> Void = { [weak self] args, closeHandler in
        guard let self else { return }

        let coordinator = TodoDetailCoordinator(
            dependency: TodoDetailCoordinator.Dependency(
                navigationController: self.dependency.navigationController,
                injector: self.dependency.injector,
                closeHandler: closeHandler
            )
        )
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(type: .memberTodo, args: args)
    }
    
    lazy var showMyPage: (Profile) -> Void = { [weak self] profile in
        guard let self else { return }
        
        let vc = self.dependency.injector.resolve(
            MyPageMainViewController.self,
            argument: MyPageMainViewModel.Injectable(
                actions: .init(),
                args: .init(profile: profile)
            )
        )
        vc.hidesBottomBarWhenPushed = true
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
}

extension HomeCalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
