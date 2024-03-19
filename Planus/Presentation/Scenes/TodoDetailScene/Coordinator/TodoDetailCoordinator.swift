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
    
    var type: CoordinatorType = .homeCalendar
    var viewController: TodoDetailViewController?
        
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(type: TodoDetailSceneType, args: TodoDetailViewModelArgs) {
        switch type {
        case .memberTodo:
            showMemberTodoDetail(args)
        case .socialTodo:
            showSocialTodoDetail()
        }
    }
    
    lazy var showSocialTodoDetail: () -> Void = { [weak self] in
        
    }
    
    lazy var showMemberTodoDetail: (TodoDetailViewModelArgs) -> Void = { [weak self] args in
        guard let self else { return }
        let vc = self.dependency.injector.resolve(
            TodoDetailViewController.self,
            name: PresentationAssembly.TodoDetailPageType.memberTodo.rawValue,
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
    }
}

extension TodoDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}