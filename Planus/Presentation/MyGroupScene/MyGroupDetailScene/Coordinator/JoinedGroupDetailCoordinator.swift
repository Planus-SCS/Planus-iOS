//
//  JoinedGroupDetailCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit

class JoinedGroupDetailCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .joinedGroup
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(id: Int) {
        showGroupDetailPage(id)
    }
    
    lazy var showGroupDetailPage: (Int) -> Void = { [weak self] id in
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let fetchMyGroupDetailUseCase = DefaultFetchMyGroupDetailUseCase(myGroupRepository: myGroupRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let setOnlineStateUseCase = DefaultSetOnlineUseCase.shared
//        let vm = JoinedGroupDetailViewModel(
//            getTokenUseCase: getTokenUseCase,
//            refreshTokenUseCase: refreshTokenUseCase,
//            fetchMyGroupDetailUseCase: fetchMyGroupDetailUseCase,
//            fetchImageUseCase: fetchImageUseCase,
//            setOnlineUseCase: setOnlineStateUseCase,
//            updateNoticeUseCase: DefaultUpdateNoticeUseCase.shared,
//            updateInfoUseCase: DefaultUpdateGroupInfoUseCase.shared,
//            withdrawGroupUseCase: DefaultWithdrawGroupUseCase.shared
//        )
//        vm.setGroupId(id: id)
//        vm.setActions(actions: JoinedGroupDetailViewModelActions(pop: self?.popCurrentPage))
//
//        let vc = JoinedGroupDetailViewController(viewModel: vm)
        let groupCalendarRepo = DefaultGroupCalendarRepository(apiProvider: api)
        let groupCategoryRepo = DefaultGroupCategoryRepository(apiProvider: api)
        let updateNoticeUseCase = DefaultUpdateNoticeUseCase.shared
        let updateInfoUseCase = DefaultUpdateGroupInfoUseCase.shared
        let withdrawGroupUseCase = DefaultWithdrawGroupUseCase.shared
        let fetchMyGroupMemberListUseCase = DefaultFetchMyGroupMemberListUseCase(myGroupRepository: myGroupRepo)
        let memberKickOutUseCase = DefaultMemberKickOutUseCase.shared
        let createMonthlyCalendarUseCase = DefaultCreateMonthlyCalendarUseCase()
        let fetchMyGroupCalendarUseCase = DefaultFetchGroupMonthlyCalendarUseCase(groupCalendarRepository: groupCalendarRepo)
        let createGroupTodoUseCase = DefaultCreateGroupTodoUseCase.shared
        let updateGroupTodoUseCase = DefaultUpdateGroupTodoUseCase.shared
        let deleteGroupTodoUseCase = DefaultDeleteGroupTodoUseCase.shared
        let updateGroupCategoryUseCase = DefaultUpdateGroupCategoryUseCase.shared
        
        
        let vm = MyGroupDetailViewModel2(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            fetchMyGroupDetailUseCase: fetchMyGroupDetailUseCase,
            fetchImageUseCase: fetchImageUseCase,
            setOnlineUseCase: setOnlineStateUseCase,
            updateNoticeUseCase: updateNoticeUseCase,
            updateInfoUseCase: updateInfoUseCase,
            withdrawGroupUseCase: withdrawGroupUseCase,
            fetchMyGroupMemberListUseCase: fetchMyGroupMemberListUseCase,
            memberKickOutUseCase: memberKickOutUseCase,
            createMonthlyCalendarUseCase: createMonthlyCalendarUseCase,
            fetchMyGroupCalendarUseCase: fetchMyGroupCalendarUseCase,
            createGroupTodoUseCase: createGroupTodoUseCase,
            updateGroupTodoUseCase: updateGroupTodoUseCase,
            deleteGroupTodoUseCase: deleteGroupTodoUseCase,
            updateGroupCategoryUseCase: updateGroupCategoryUseCase
        )
        vm.groupId = id
        let vc = MyGroupDetailViewController2(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true

        self?.navigationController.pushViewController(vc, animated: true)
    }

    lazy var popCurrentPage: () -> Void = { [weak self] in
        self?.navigationController.popViewController(animated: true)
    }

}

extension JoinedGroupDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}

