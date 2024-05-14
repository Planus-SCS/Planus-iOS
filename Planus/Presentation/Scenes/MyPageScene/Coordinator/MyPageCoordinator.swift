//
//  MyPageCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 3/10/24.
//

import UIKit
import RxSwift

final class MyPageCoordinator: Coordinator {
    
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

        let vm = self.dependency.injector.resolve(
            MyPageMainViewModel.self,
            injectable: MyPageMainViewModel.Injectable(
                actions: .init(
                    editProfile: self.editProfile,
                    showTermsOfUse: self.showTermsOfUse,
                    showPrivacyPolicy: self.showPrivacyPolicy,
                    backToSignIn: self.backToSignIn,
                    pop: self.goBack,
                    finish: self.finish
                ),
                args: MyPageMainViewModel.Args(profile: profile)
            )
        )
        
        let vc = MyPageMainViewController(viewModel: vm)
        
        vc.hidesBottomBarWhenPushed = true
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var editProfile: () -> Void = { [weak self] in
        guard let self else { return }

        let vm = self.dependency.injector.resolve(
            MyPageEditViewModel.self,
            injectable: MyPageEditViewModel.Injectable(
                actions: .init(
                    goBack: self.goBack
                ),
                args: .init()
            )
        )
        
        let vc = MyPageEditViewController(viewModel: vm)
        
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showTermsOfUse: (() -> Void)? = { [weak self] in
        guard let self else { return }
        
        let vm = dependency.injector.resolve(
            MyPageReadableViewModel.self,
            injectable: MyPageReadableViewModel.Injectable(
                actions: .init(goBack: self.goBack),
                args: .init(type: .serviceTerms)
            )
        )
        
        let vc = MyPageReadableViewController(viewModel: vm)
        
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showPrivacyPolicy: (() -> Void)? = { [weak self] in
        guard let self else { return }
        
        let vm = dependency.injector.resolve(
            MyPageReadableViewModel.self,
            injectable: MyPageReadableViewModel.Injectable(
                actions: .init(goBack: self.goBack),
                args: .init(type: .privacyPolicy)
            )
        )
        
        let vc = MyPageReadableViewController(viewModel: vm)
        
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
