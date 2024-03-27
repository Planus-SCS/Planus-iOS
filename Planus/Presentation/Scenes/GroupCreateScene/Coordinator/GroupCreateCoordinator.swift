//
//  GroupCreateCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

final class GroupCreateCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .groupCreate
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start() {
        showGroupCreatePage()
    }
    
    
    lazy var showGroupCreatePage: () -> Void = { [weak self] in
        guard let self else { return }
        let vc = dependency.injector.resolve(
            GroupCreateViewController.self,
            argument: GroupCreateViewModel.Injectable(
                actions: .init(
                    showGroupCreateLoadPage: self.showGroupCreateLoadPage,
                    pop: pop,
                    finishScene: finishScene
                ),
                args: .init()
            )
        )
        
        vc.hidesBottomBarWhenPushed = true

        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showGroupCreateLoadPage: (MyGroupCreationInfo, ImageFile) -> Void = { [weak self] (info, image) in
        guard let self else { return }
        let vc = dependency.injector.resolve(
            GroupCreateLoadViewController.self,
            argument: GroupCreateLoadViewModel.Injectable(
                actions: .init(
                    showCreatedGroupPage: self.showCreatedGroupPage,
                    backWithCreateFailure: self.backWithCreateFailure
                ),
                args: .init(
                    groupCreationInfo: info,
                    groupImage: image
                )
            )
        )

        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showCreatedGroupPage: (Int) -> Void = { [weak self] groupId in
        guard let self else { return }
        let coordinator = MyGroupDetailCoordinator(
            dependency: MyGroupDetailCoordinator.Dependency(
                navigationController: self.dependency.navigationController,
                injector: self.dependency.injector
            )
        )
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(groupId: groupId)
        
        var children = dependency.navigationController.viewControllers
        children.removeAll(where: { childVC in
            switch childVC {
            case is GroupCreateViewController:
                return true
            case is GroupCreateLoadViewController:
                return true
            default:
                return false
            }
        })
        
        dependency.navigationController.setViewControllers(children, animated: true)
    }
    
    lazy var backWithCreateFailure: (String) -> Void = { [weak self] message in
        guard let self else { return }
        self.pop()
        
        guard let exVC = self.dependency.navigationController.viewControllers.first(where: { $0 is GroupCreateViewController }) as? GroupCreateViewController else { return }
        exVC.viewModel?.nowSaving = false
        exVC.view.endEditing(true)

        dependency.navigationController.showToast(message: message, type: .warning)
    }

    lazy var pop: () -> Void = { [weak self] in
        self?.dependency.navigationController.popViewController(animated: true)
    }
    
    lazy var finishScene: () -> Void = { [weak self] in
        guard let self else { return }
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension GroupCreateCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

