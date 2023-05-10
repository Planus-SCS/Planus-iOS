//
//  AppCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit
import RxSwift

final class AppCoordinator: Coordinator {
    
    var bag = DisposeBag()
        
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
        checkAutoSignIn()
    }
    
    private func checkAutoSignIn() {
        // 우선 여기서 자동로그인이 되있는지를 봐야한다..!
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let setTokenUseCase = DefaultSetTokenUseCase(tokenRepository: tokenRepo)
        if let observable = refreshTokenUseCase.execute() {
            observable
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { [weak self] token in //토큰 리프레시 성공한거임. 메인탭으로
                    print("newToken: ", token)
                    setTokenUseCase.execute(token: token)
                    self?.showMainTabFlow()
                }, onFailure: { [weak self] error in
                    print(error)
                    self?.showSignInFlow()
                })
                .disposed(by: bag)
        } else { //아에 존재조차 안함. signin 창으로 보내야함
            showSignInFlow()
        }
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
