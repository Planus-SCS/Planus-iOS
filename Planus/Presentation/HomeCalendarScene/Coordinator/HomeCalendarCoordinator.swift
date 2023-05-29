//
//  HomeCalendarCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit

class HomeCalendarCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .homeCalendar
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showHomeCalendarPage()
    }
    
    lazy var showHomeCalendarPage: () -> Void = { [weak self] in
        
        let apiProvider = NetworkManager()
        let keyChain = KeyChainManager()
        
        let todoRepository = TestTodoDetailRepository(apiProvider: apiProvider)
        let tokenRepository = DefaultTokenRepository(apiProvider: apiProvider, keyChainManager: keyChain)
        let categoryRepository = DefaultCategoryRepository(apiProvider: apiProvider)
        let profileRepository = DefaultProfileRepository(apiProvider: apiProvider)
        let myGroupRepository = DefaultMyGroupRepository(apiProvider: apiProvider)
        let createMonthlyCalendarUseCase = DefaultCreateMonthlyCalendarUseCase()
        let readTodoListUseCase = DefaultReadTodoListUseCase(todoRepository: todoRepository)
        let dateFormatYYYYMMUseCase = DefaultDateFormatYYYYMMUseCase()
        let createTodoUseCase = DefaultCreateTodoUseCase.shared
        let updateTodoUseCase = DefaultUpdateTodoUseCase.shared
        let deleteTodoUseCase = DefaultDeleteTodoUseCase.shared
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepository)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepository)
        let createCategoryUseCase = DefaultCreateCategoryUseCase.shared
        let readCategoryUseCase = DefaultReadCategoryListUseCase(categoryRepository: categoryRepository)
        let updateCategoryUseCase = DefaultUpdateCategoryUseCase.shared
        let deleteCategoryUseCase = DefaultDeleteCategoryUseCase.shared
        let readProfileUseCase = DefaultReadProfileUseCase(profileRepository: profileRepository)
        let updateProfileUseCase = DefaultUpdateProfileUseCase.shared
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: DefaultImageRepository.shared)
        let fetchMyGroupNameListUseCase = DefaultFetchMyGroupNameListUseCase(myGroupRepo: myGroupRepository)
        let vm = HomeCalendarViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            createTodoUseCase: createTodoUseCase,
            readTodoListUseCase: readTodoListUseCase,
            updateTodoUseCase: updateTodoUseCase,
            deleteTodoUseCase: deleteTodoUseCase,
            createCategoryUseCase: createCategoryUseCase,
            readCategoryListUseCase: readCategoryUseCase,
            updateCategoryUseCase: updateCategoryUseCase,
            deleteCategoryUseCase: deleteCategoryUseCase,
            fetchMyGroupNameListUseCase: fetchMyGroupNameListUseCase,
            groupCreateUseCase: DefaultGroupCreateUseCase.shared,
            createMonthlyCalendarUseCase: createMonthlyCalendarUseCase,
            dateFormatYYYYMMUseCase: dateFormatYYYYMMUseCase,
            readProfileUseCase: readProfileUseCase,
            updateProfileUseCase: updateProfileUseCase,
            fetchImageUseCase: fetchImageUseCase,
            withdrawGroupUseCase: DefaultWithdrawGroupUseCase.shared
        )

        let vc = HomeCalendarViewController(viewModel: vm)
        self?.navigationController.pushViewController(vc, animated: true)
    }
    
    lazy var showTodoModal: () -> Void = { [weak self] in
    }
    
    lazy var showMyPage: () -> Void = {
        
    }
}

extension HomeCalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
