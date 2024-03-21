//
//  TodoDetailCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/10/24.
//

import UIKit
import RxSwift

class TodoDetailCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
        let closeHandler: (() -> Void)?
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .todoDetail
    
    var viewController: TodoDetailViewController?
        
    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func startMember(args: MemberTodoDetailViewModel.Args) {
        showMemberTodoDetail(args)
    }
    func startSocial(args: SocialTodoDetailViewModel.Args) {
        showSocialTodoDetail(args)
    }
    
    lazy var showSocialTodoDetail: (SocialTodoDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vc = self.dependency.injector.resolve(
            TodoDetailViewController.self,
            name: TodoDetailPresentationAssembly.TodoDetailPageType.socialTodo.rawValue,
            argument: SocialTodoDetailViewModel.Injectable(
                actions: TodoDetailViewModelActions(close: close),
                args: args
            )
        )
        
        vc.pageDismissCompletionHandler = dependency.closeHandler
        self.viewController = vc
        vc.modalPresentationStyle = .overFullScreen
        dependency.navigationController.present(vc, animated: false, completion: nil)
    }
    
    lazy var showMemberTodoDetail: (MemberTodoDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vc = self.dependency.injector.resolve(
            TodoDetailViewController.self,
            name: TodoDetailPresentationAssembly.TodoDetailPageType.memberTodo.rawValue,
            argument: MemberTodoDetailViewModel.Injectable(
                actions: TodoDetailViewModelActions(close: close),
                args: args
            )
        )
        
        vc.pageDismissCompletionHandler = dependency.closeHandler
        self.viewController = vc
        vc.modalPresentationStyle = .overFullScreen
        dependency.navigationController.present(vc, animated: false, completion: nil)
    }
    
    lazy var close: () -> Void = { [weak self] in
        guard let self else { return }
        self.viewController?.dismiss(animated: true)
        self.finish()
    }
}

extension TodoDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
