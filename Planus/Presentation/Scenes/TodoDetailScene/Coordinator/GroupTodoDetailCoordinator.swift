//
//  GroupTodoDetailCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import UIKit
import RxSwift

final class GroupTodoDetailCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .groupTodoDetail
    
    var modalNavigation: UINavigationController?
        
    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func start(args: GroupTodoDetailViewModel.Args) {
        showGroupTodoDetail(args)
    }
    
    lazy var showGroupTodoDetail: (GroupTodoDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            GroupTodoDetailViewModel.self,
            injectable: GroupTodoDetailViewModel.Injectable(
                actions: .init(
                    showCategorySelect: showGroupCategorySelect,
                    dismiss: close
                ),
                args: args
            )
        )
        
        let vc = TodoDetailViewController(viewModel: vm)
        
        let navigation = TodoDetailNavigationController(rootViewController: vc)
        navigation.isNavigationBarHidden = true
        self.modalNavigation = navigation
                
        navigation.modalPresentationStyle = .overFullScreen
        dependency.navigationController.present(navigation, animated: false, completion: nil)
    }

    lazy var showGroupCategorySelect: (GroupCategorySelectViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            GroupCategorySelectViewModel.self,
            injectable: GroupCategorySelectViewModel.Injectable(
                actions: .init(
                    showCategoryCreate: showGroupCategoryDetail,
                    pop: pop,
                    dismiss: close
                ),
                args: args
            )
        )
        
        let vc = CategorySelectViewController(viewModel: vm)
        modalNavigation?.pushViewController(vc, animated: true)
    }
    
    lazy var showGroupCategoryDetail: (GroupCategoryDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            GroupCategoryDetailViewModel.self,
            injectable: GroupCategoryDetailViewModel.Injectable(
                actions: .init(
                    pop: pop,
                    dismiss: close
                ),
                args: args
            )
        )
        
        let vc = CategoryDetailViewController(viewModel: vm)
        modalNavigation?.pushViewController(vc, animated: true)
    }
    
    lazy var pop: () -> Void = { [weak self] in
        self?.modalNavigation?.popViewController(animated: true)
    }
    
    lazy var close: () -> Void = { [weak self] in
        guard let self else { return }
        self.modalNavigation?.dismiss(animated: false)
        self.finish()
    }
}

extension GroupTodoDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
