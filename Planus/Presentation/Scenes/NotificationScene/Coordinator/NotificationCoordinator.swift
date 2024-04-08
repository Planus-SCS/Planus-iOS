//
//  NotificationCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/20/24.
//

import UIKit
import RxSwift

final class NotificationCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .notification
    
    var modalNavigationVC: UINavigationController?
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start() {
        showNotificationPage()
    }
    
    lazy var showNotificationPage: () -> Void = { [weak self] in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            NotificationViewModel.self,
            injectable: NotificationViewModel.Injectable(
                actions: .init(
                    pop: self.pop,
                    finishScene: self.finishScene
                ),
                args: .init()
            )
        )
        
        let vc = NotificationViewController(viewModel: vm)
        
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var pop: () -> Void = { [weak self] in
        self?.dependency.navigationController.popViewController(animated: true)
    }
    
    lazy var finishScene: (() -> Void)? = { [weak self] in
        self?.finish()
    }

}

extension NotificationCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

