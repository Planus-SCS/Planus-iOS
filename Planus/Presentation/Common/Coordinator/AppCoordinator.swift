//
//  AppCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

final class AppCoordinator: Coordinator {
        
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var window: UIWindow
        
    var childCoordinators: [Coordinator] = []

    var type: CoordinatorType = .app
            
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        /*
         자동 로그인 여부에 따라 로그인 로직 or 메인화면 로직 실행
         */
        showSignInFlow()
    }
    
    private func checkAutoSignIn() -> Bool {
        return true
    }
    
    func showSignInFlow() {
        let navigation = UINavigationController()
        window.rootViewController = navigation

        let signInCoordinator = SignInCoordinator(navigationController: navigation)
        signInCoordinator.finishDelegate = self
        signInCoordinator.start()
        childCoordinators.append(signInCoordinator)
        
        window.makeKeyAndVisible()
    }
    
    func showMainTabFlow() {
        DispatchQueue.main.async { [weak self] in
            let navigation = UINavigationController()
            self?.window.rootViewController = navigation

            let tabCoordinator = MainTabCoordinator(navigationController: navigation)
            tabCoordinator.finishDelegate = self
            tabCoordinator.start()
            self?.childCoordinators.append(tabCoordinator)
            
            self?.window.makeKeyAndVisible()
            self?.viewTransitionAnimation()
        }
    }
    
    func viewTransitionAnimation() {
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

    
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
