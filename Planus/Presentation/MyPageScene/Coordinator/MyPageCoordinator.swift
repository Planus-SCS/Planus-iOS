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
                    showTermsOfUse: self.showTermsOfUse,
                    showPrivacyPolicy: self.showPrivacyPolicy,
                    signOut: self.signOut,
                    withdraw: self.withdraw
                ),
                args: .init(profile: profile)
            )
        )
    }
    
    lazy var showTermsOfUse: (() -> Void)? = { [weak self] in
        guard let self else { return }
        
        let vc = dependency.injector.resolve(
            MyPageReadableViewController.self,
            argument: MyPageReadableViewModel.Injectable(
                actions: .init(),
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
                actions: .init(),
                args: .init(type: .privacyPolicy)
            )
        )
        
        dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var signOut: (() -> Void)? = { [weak self] in
        
    }
    
    lazy var withdraw: (() -> Void)? = { [weak self] in
        
    }

}

extension MyPageCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
