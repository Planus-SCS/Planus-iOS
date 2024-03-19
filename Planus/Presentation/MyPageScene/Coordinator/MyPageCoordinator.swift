//
//  MyPageCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/10/24.
//

import UIKit
import RxSwift

class MyPageCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    weak var finishDelegate: CoordinatorFinishDelegate?
    
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .homeCalendar
    var viewController: TodoDetailViewController?
        
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start(profile: Profile) {
        showMyPageMain(profile)
    }
    
    lazy var showMyPageMain: (Profile) -> Void = { [weak self] profile in
        guard let self else { return }
        let vc = self.dependency.injector.resolve(
            MyPageMainViewController.self,
            argument: MyPageMainViewModel.Injectable(
                actions: .init(
                    editProfile: self.editProfile,
                    showTermsOfUse: self.showTermsOfUse,
                    showPrivacyPolicy: self.showPrivacyPolicy,
                    backToSignIn: self.backToSignIn,
                    finish: self.finish
                ),
                args: .init(profile: profile)
            )
        )
        vc.hidesBottomBarWhenPushed = true
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var editProfile: () -> Void = { [weak self] in
        guard let self else { return }
        let vc = self.dependency.injector.resolve(
            MyPageEditViewController.self,
            argument: MyPageEditViewModel.Injectable(
                actions: .init(
                    goBack: self.goBack
                ),
                args: .init()
            )
        )
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showTermsOfUse: (() -> Void)? = { [weak self] in
        guard let self else { return }
        
        let vc = dependency.injector.resolve(
            MyPageReadableViewController.self,
            argument: MyPageReadableViewModel.Injectable(
                actions: .init(goBack: self.goBack),
                args: .init(type: .serviceTerms)
            )
        )
        
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showPrivacyPolicy: (() -> Void)? = { [weak self] in
        guard let self else { return }
        
        let vc = dependency.injector.resolve(
            MyPageReadableViewController.self,
            argument: MyPageReadableViewModel.Injectable(
                actions: .init(goBack: self.goBack),
                args: .init(type: .privacyPolicy)
            )
        )
        
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var goBack: (() -> Void)? = { [weak self] in
        guard let self else { return }
        self.dependency.navigationController.popViewController(animated: true)
    }
    
    lazy var backToSignIn: (() -> Void)? = { [weak self] in
        guard let self else { return }
        guard let sceneDelegate = self.dependency.navigationController.view.window?.windowScene?.delegate as? SceneDelegate,
              let appCoordinator = sceneDelegate.appCoordinator else { return }
        
        appCoordinator.childCoordinators.first(where: { $0 is MainTabCoordinator })?.finish()
        appCoordinator.showSignInFlow()
    }
}

extension MyPageCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
