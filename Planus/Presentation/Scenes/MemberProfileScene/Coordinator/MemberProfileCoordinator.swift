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

        
    }

}

extension MemberProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
