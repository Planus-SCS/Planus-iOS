//
//  TodoDetailCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/10/24.
//

import UIKit
import RxSwift

final class MyTodoDetailCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
        let closeHandler: (() -> Void)?
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .myTodoDetail
    
    var modalNavigation: UINavigationController?
        
    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func start(args: MyTodoDetailViewModel.Args) {
        showMyTodoDetail(args)
    }

    lazy var showMyTodoDetail: (MyTodoDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            MyTodoDetailViewModel.self,
            injectable: MyTodoDetailViewModel.Injectable(
                actions: .init(
                    showCategorySelect: showMyCategorySelect,
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
    
    lazy var showMyCategorySelect: (MyCategorySelectViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            MyCategorySelectViewModel.self,
            injectable: MyCategorySelectViewModel.Injectable(
                actions: .init(
                    showCategoryCreate: showMyCategoryDetail,
                    pop: pop,
                    dismiss: close
                ),
                args: args
            )
        )
        
        let vc = CategorySelectViewController(viewModel: vm)
        modalNavigation?.pushViewController(vc, animated: true)
    }
    
    lazy var showMyCategoryDetail: (MyCategoryDetailViewModel.Args) -> Void = { [weak self] args in
        guard let self else { return }
        let vm = self.dependency.injector.resolve(
            MyCategoryDetailViewModel.self,
            injectable: MyCategoryDetailViewModel.Injectable(
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
        self.modalNavigation?.dismiss(animated: false) {
            self.dependency.closeHandler?()
        }
        self.finish()
    }
}

extension MyTodoDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

