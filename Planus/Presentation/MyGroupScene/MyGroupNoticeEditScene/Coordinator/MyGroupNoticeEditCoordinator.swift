//
//  MyGroupNoticeEditCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit

class MyGroupNoticeEditCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .noticeEdit
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // 시작할때 노티스, 그룹 아이디가 필요함!
    func start(groupId: String, notice: String) {
        showNoticeEditPage(groupId, notice)
    }
    
    lazy var showNoticeEditPage: (String, String) -> Void = { [weak self] id, notice in

//        let vm = 

    }

    lazy var popCurrentPage: () -> Void = { [weak self] in
        self?.navigationController.popViewController(animated: true)
        self?.didPop()
    }
    
    lazy var didPop: () -> Void = { [weak self] in
        guard let self else { return }
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension MyGroupNoticeEditCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
