//
//  MemberProfileCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import UIKit

class MemberProfileCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .memberProfile
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(args: MemberProfileViewModel.Args) {
        showMemberProfilePage(args)
    }
    
    lazy var showMemberProfilePage: (MemberProfileViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        
        let vc = dependency.injector.resolve(
            MemberProfileViewController.self,
            argument: MemberProfileViewModel.Injectable(
                actions: .init(
                    showSocialDailyCalendar: self.showSocialDailyCalendar,
                    pop: self.pop,
                    finishScene: self.finishScene
                ),
                args: args
            )
        )
        vc.hidesBottomBarWhenPushed = true
        dependency.navigationController.pushViewController(vc, animated: true)
        
    }
    
    lazy var showSocialDailyCalendar: (() -> Void) = {}
    lazy var pop: (() -> Void) = { [weak self] in
        self?.dependency.navigationController.popViewController(animated: true)
    }
    
    lazy var finishScene: (() -> Void) = { [weak self] in
        self?.finish()
    }
}

extension MemberProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
