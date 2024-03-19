//
//  GroupCreateCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupCreateCoordinator: Coordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    let dependency: Dependency
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .groupCreate
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func start() {
        showGroupCreatePage()
    }
    
    
    lazy var showGroupCreatePage: () -> Void = { [weak self] in
        guard let self else { return }
        let vc = dependency.injector.resolve(
            GroupCreateViewController.self,
            argument: GroupCreateViewModel.Injectable(
                actions: .init(
                    showGroupCreateLoadPage: self.showGroupCreateLoadPage,
                    finishSceneWithPop: finishSceneWithPop,
                    finishScene: finishScene
                ),
                args: .init()
            )
        )
        
        vc.hidesBottomBarWhenPushed = true

        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showGroupCreateLoadPage: (MyGroupCreationInfo, ImageFile) -> Void = { [weak self] (info, image) in
        guard let self else { return }
        let vc = dependency.injector.resolve(
            GroupCreateLoadViewController.self,
            argument: GroupCreateLoadViewModel.Injectable(
                actions: .init(
                    showCreatedGroupPage: self.showCreatedGroupPage,
                    backWithCreateFailure: self.backWithCreateFailure
                ),
                args: .init(
                    groupCreationInfo: info,
                    groupImage: image
                )
            )
        )

        self.dependency.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showCreatedGroupPage: (Int) -> Void = { [weak self] groupId in
        guard let self else { return }
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyValueStorage: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let fetchMyGroupDetailUseCase = DefaultFetchMyGroupDetailUseCase(myGroupRepository: myGroupRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let setOnlineStateUseCase = DefaultSetOnlineUseCase.shared
        let myGroupDetailVM = JoinedGroupDetailViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            fetchMyGroupDetailUseCase: fetchMyGroupDetailUseCase,
            fetchImageUseCase: fetchImageUseCase,
            setOnlineUseCase: setOnlineStateUseCase,
            updateNoticeUseCase: DefaultUpdateNoticeUseCase.shared,
            updateInfoUseCase: DefaultUpdateGroupInfoUseCase.shared,
            withdrawGroupUseCase: DefaultWithdrawGroupUseCase.shared
        )
        myGroupDetailVM.setGroupId(id: groupId)
        myGroupDetailVM.setActions(actions: JoinedGroupDetailViewModelActions(pop: {
            self.dependency.navigationController.popViewController(animated: true)
        }))
        let myGroupDetailVC = JoinedGroupDetailViewController(viewModel: myGroupDetailVM)
        
        var children = dependency.navigationController.viewControllers
        children.removeAll(where: { childVC in
            switch childVC {
            case is GroupCreateViewController:
                return true
            case is GroupCreateLoadViewController:
                return true
            default:
                return false
            }
        })
        children.append(myGroupDetailVC)
        
        dependency.navigationController.setViewControllers(children, animated: true)
    }
    
    lazy var backWithCreateFailure: (String) -> Void = { [weak self] message in
        guard let self else { return }
        self.dependency.navigationController.popViewController(animated: true)
        
        guard let exVC = self.dependency.navigationController.viewControllers.first(where: { $0 is GroupCreateViewController }) as? GroupCreateViewController else { return }
        exVC.viewModel?.nowSaving = false
        exVC.view.endEditing(true)

        exVC.showToast(message: message, type: .warning)
    }

    lazy var finishSceneWithPop: () -> Void = { [weak self] in
        self?.dependency.navigationController.popViewController(animated: true)
        self?.finishScene()
    }
    
    lazy var finishScene: () -> Void = { [weak self] in
        guard let self else { return }
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension GroupCreateCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

