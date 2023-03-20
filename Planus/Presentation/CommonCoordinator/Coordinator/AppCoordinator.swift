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
    }
    
    private func checkAutoSignIn() -> Bool {
        return true
    }
    
    func showSignInFlow() {
        /*
         로그인 화면을 표시
         */
    }
    
    func showMainTabFlow() {
        /*
         메인 화면을 표시
         */
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
