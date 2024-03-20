//
//  GroupIntroduceCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupIntroduceCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .groupIntroduce
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(id: Int) {
        showGroupIntroducePage(id)
    }
    
    lazy var showGroupIntroducePage: (Int) -> Void = { [weak self] groupId in
        guard let self else { return }
        let vc = self.dependency.injector.resolve(
            GroupIntroduceViewController.self,
            argument: GroupIntroduceViewModel.Injectable(
                actions: .init(
                    showMyGroupDetailPage: showMyGroupDetailPage,
                    pop: pop,
                    finishScene: finishScene
                ),
                args: .init(groupId: groupId)
            )
        )
        
        vc.hidesBottomBarWhenPushed = true

        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showMyGroupDetailPage: (Int) -> Void = { [weak self] groupId in
        
    }
    
    lazy var fetchFailed: (String) -> Void = { [weak self] message in
        self?.pop()
        self?.dependency.navigationController.topViewController?.showToast(message: message, type: .warning)
    }

    lazy var pop: () -> Void = { [weak self] in
        self?.dependency.navigationController.popViewController(animated: true)
    }
    
    lazy var finishScene: () -> Void = { [weak self] in
        guard let self else { return }
        self.finish()
    }
}

extension GroupIntroduceCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}