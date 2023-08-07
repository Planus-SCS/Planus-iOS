//
//  SignInCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

class SignInCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .signIn
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLoginPage()
    }
    
    lazy var showLoginPage: () -> Void = { [weak self] in
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let repo = DefaultSocialAuthRepository(apiProvider: api)
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let kakaoSignInUseCase = DefaultKakaoSignInUseCase(socialAuthRepository: repo)
        let googleSignInUseCase = DefaultGoogleSignInUseCase(socialAuthRepository: repo)
        let appleSignInUseCase = DefaultAppleSignInUseCase(socialAuthRepository: repo)
        let setTokenUseCase = DefaultSetTokenUseCase(tokenRepository: tokenRepo)
        let vm = SignInViewModel(
            kakaoSignInUseCase: kakaoSignInUseCase,
            googleSignInUseCase: googleSignInUseCase,
            appleSignInUseCase: appleSignInUseCase,
            setTokenUseCase: setTokenUseCase
        )
        
        vm.setActions(actions:SignInViewModelActions(
            showWebViewSignInPage: self?.showWebViewSignInPage,
            showMainTabFlow: self?.showMainTabFlow
        ))
        
        let vc = SignInViewController(viewModel: vm)
        
        self?.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showWebViewSignInPage: (SocialRedirectionType, @escaping (String) -> Void) -> Void = { [weak self] type, completion in
        let vm = RedirectionalWebViewModel(type: type, completion: completion)
        let vc = RedirectionalWebViewController(viewModel: vm)
        
        self?.navigationController.present(vc, animated: true)
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
