//
//  MyGroupDetailCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import UIKit

class MyGroupDetailCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .myGroupDetail
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(groupId: Int) {
        showMyGroupDetail(groupId)
    }
    
    lazy var showMyGroupDetail: (Int) -> Void = { [weak self] groupId in
        guard let self else { return }
        
        let vc = self.dependency.injector.resolve(
            MyGroupDetailViewController.self,
            argument: MyGroupDetailViewModel.Injectable(
                actions: .init(
                    showDailyCalendar: self.showDailyCalendar,
                    showMemberProfile: self.showMemberProfile,
                    editInfo: self.showEditInfo,
                    editMember: self.showEditMember,
                    editNotice: self.showEditNotice,
                    pop: self.pop,
                    finishScene: self.finishScene
                ),
                args: .init(groupId: groupId)
            )
        )
        vc.hidesBottomBarWhenPushed = true
        
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showDailyCalendar: (SocialDailyCalendarViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let coordinator = SocialDailyCalendarCoordinator(
            dependency: SocialDailyCalendarCoordinator.Dependency(
                navigationController: self.dependency.navigationController,
                injector: self.dependency.injector
            )
        )
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(args: args)
    }
    
    lazy var showMemberProfile: (MemberProfileViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let coordinator = MemberProfileCoordinator(
            dependency: MemberProfileCoordinator.Dependency(
                navigationController: self.dependency.navigationController,
                injector: self.dependency.injector
            )
        )
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(args: args)
    }
    
    lazy var showEditInfo: (MyGroupInfoEditViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        
        let vc = self.dependency.injector.resolve(
            MyGroupInfoEditViewController.self,
            argument: MyGroupInfoEditViewModel.Injectable(
                actions: .init(
                    popDetailScene: self.popDetailScene,
                    pop: self.pop
                ),
                args: args
            )
        )
        
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showEditMember: (MyGroupMemberEditViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        
        let vc = self.dependency.injector.resolve(
            MyGroupMemberEditViewController.self,
            argument: MyGroupMemberEditViewModel.Injectable(
                actions: .init(pop: self.pop),
                args: args
            )
        )
        
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showEditNotice: (MyGroupNoticeEditViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        
        let vc = self.dependency.injector.resolve(
            MyGroupNoticeEditViewController.self,
            argument: MyGroupNoticeEditViewModel.Injectable(
                actions: .init(pop: self.pop),
                args: args
            )
        )
        
        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var pop: () -> Void = { [weak self] in
        self?.dependency.navigationController.popViewController(animated: true)
    }
    
    lazy var popDetailScene: () -> Void = { [weak self] in
        self?.dependency.navigationController.popToRootViewController(animated: true)
        self?.finish()
    }
    
    lazy var finishScene: () -> Void = { [weak self] in
        self?.finish()
    }
    
}

extension MyGroupDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
