//
//  SearchCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import UIKit

class SearchCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
        
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .search
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSearchPage()
    }
    
    lazy var showSearchPage: () -> Void = { [weak self] in

    }

    lazy var showSearchResultPage: () -> Void = { [weak self] in
        
    }
    
    lazy var showGroupSummaryPage: () -> Void = { [weak self] in
        
    }
}

extension SearchCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
