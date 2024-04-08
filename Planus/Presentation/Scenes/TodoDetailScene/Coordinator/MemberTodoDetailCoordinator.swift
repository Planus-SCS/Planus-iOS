//
//  MemberTodoDetailCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import UIKit
import RxSwift

final class MemberTodoDetailCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .memberTodoDetail
    
    var modalNavigation: UINavigationController?
        
    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func start(args: MemberTodoDetailViewModel.Args) {
        showMemberTodoDetail(args)
    }
    
    lazy var showMemberTodoDetail: (MemberTodoDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            MemberTodoDetailViewModel.self,
            injectable: MemberTodoDetailViewModel.Injectable(
                actions: .init(
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
    
    lazy var pop: () -> Void = { [weak self] in
        self?.modalNavigation?.popViewController(animated: true)
    }
    
    lazy var close: () -> Void = { [weak self] in
        guard let self else { return }
        self.modalNavigation?.dismiss(animated: false)
        self.finish()
    }
}

extension MemberTodoDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

