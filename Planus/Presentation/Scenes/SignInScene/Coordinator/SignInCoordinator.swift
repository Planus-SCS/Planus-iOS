//
//  SignInCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

final class SignInCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .signIn
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start() {
        showSignInPage()
    }
    
    lazy var showSignInPage: () -> Void = { [weak self] in
        guard let self else { return }
        
        let vm = self.dependency.injector.resolve(
            SignInViewModel.self,
            injectable: SignInViewModel.Injectable(
                actions: .init(
                    showWebViewSignInPage: self.showWebViewSignInPage,
                    showMainTabFlow: self.showMainTabFlow
                ),
                args: .init()
            )
        )
        
        let vc = SignInViewController(viewModel: vm)
        
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showWebViewSignInPage: (SocialRedirectionType, @escaping (String) -> Void) -> Void = { [weak self] type, completion in
        guard let self else { return }
        
        let vm = self.dependency.injector.resolve(
            RedirectionalWebViewModel.self,
            injectable: RedirectionalWebViewModel.Injectable(
                actions: .init(dismissWithOutAuth: nil),
                args: .init(type: type, completion: completion)
            )
        )
        
        let vc = RedirectionalWebViewController(viewModel: vm)
        
        self.dependency.navigationController.present(vc, animated: true)
    }
    
    lazy var showMainTabFlow: () -> Void = { [weak self] in
        guard let appCoordinator = self?.finishDelegate as? AppCoordinator else { return }
        
        self?.finish()
        appCoordinator.showMainTabFlow()
    }
}

extension SignInCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
