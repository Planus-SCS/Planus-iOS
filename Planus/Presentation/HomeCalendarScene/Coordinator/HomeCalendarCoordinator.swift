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
                    showMyPage: self.showMyPage
                ),
                args: .init()
            )
        )
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showDailyCalendarPage: (TodoDailyViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let viewController = self.dependency.injector.resolve(
            TodoDailyViewController.self,
            argument: TodoDailyViewModel.Injectable(
                actions: .init(),
                args: args
            )
        )
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        dependency.navigationController.present(nav, animated: true)
    }
    
    lazy var showCreatePeriodTodoPage: (Date, Date) -> Void = { startDate, endDate in
        
        
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
