//
//  AppCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit
import RxSwift

final class AppCoordinator: Coordinator {
    
    /*
     큐를 하나 만들어서 메인탭이 실행된 뒤에 가야할 길을 넣어두기..? 그럼 로그인 후에도 그쪽으로 갈듯?
     아니면 로그인이 필요하다고 하고 끝내??
     */
    
    var bag = DisposeBag()
        
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var window: UIWindow
        
    var childCoordinators: [Coordinator] = []
    var actionAfterSignInQueue: [() -> Void] = []

    var type: CoordinatorType = .app
            
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
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
        let fcmRepo = DefaultFCMRepository(apiProvider: api)
        getTokenUseCase
            .execute()
            .flatMap { _ in refreshTokenUseCase.execute() }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] token in
                guard let self else { return }
                self.showMainTabFlow()
                DispatchQueue.main.async {
                    while !self.actionAfterSignInQueue.isEmpty {
                        let action = self.actionAfterSignInQueue.removeFirst()
                        action()
                    }
                }
            }, onFailure: { [weak self] error in
                if let ne = error as? NetworkManagerError,
                   case NetworkManagerError.clientError(let int, let string) = ne {
                    print(string)
                }
                print("signIn!!")
                self?.showSignInFlow()
            })
            .disposed(by: bag)
        
        // 마지막으로 리프레시 된놈을 얻어와야한다..!
            
    }
    
    func showSignInFlow() {
        let navigation = UINavigationController()
        window.rootViewController = navigation

        let signInCoordinator = SignInCoordinator(navigationController: navigation)
        signInCoordinator.finishDelegate = self
        signInCoordinator.start()
        childCoordinators.removeAll()
        childCoordinators.append(signInCoordinator)
        
        window.makeKeyAndVisible()
    }
    
    func showMainTabFlow() {
        DispatchQueue.main.async { [weak self] in
            print("showMainTabFlow")
            let navigation = UINavigationController()
            self?.window.rootViewController = navigation

            let tabCoordinator = MainTabCoordinator(navigationController: navigation)
            tabCoordinator.finishDelegate = self
            tabCoordinator.start()
            self?.childCoordinators.append(tabCoordinator)
            
            self?.window.makeKeyAndVisible()
            self?.viewTransitionAnimation()
            
//            self?.patchFCMToken()
        }
    }
    
    func viewTransitionAnimation() {
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

    func appendActionAfterAutoSignIn(action: @escaping () -> Void) {
        actionAfterSignInQueue.append(action)
    }
    
    func patchFCMToken() {
        let api = NetworkManager()
        let keyChainManager = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChainManager)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let fcmRepo = DefaultFCMRepository(apiProvider: NetworkManager())

        guard let fcm = UserDefaultsManager().get(key: "fcmToken") as? String else { return }

        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                fcmRepo.patchFCMToken(token: token.accessToken, fcmToken: fcm).map { _ in () }
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                print("fcm patch success")
            }, onFailure: { [weak self] error in
                print(error)
            })
            .disposed(by: bag)
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
