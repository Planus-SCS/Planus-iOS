//
//  MainTabCoordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

enum TabBarPage: Int, CaseIterable {
    case calendar = 0
    case todo = 1
    case search = 2
    case group = 3
    
    func pageTitleValue() -> String {
        switch self {
        case .calendar:
            return "캘린더"
        case .todo:
            return "투두"
        case .search:
            return "검색"
        case .group:
            return "그룹"
        }
    }
    
    func pageTabIcon() -> UIImage? {
        switch self {
        case .calendar:
            return UIImage(named: "calendarTab")
        case .todo:
            return UIImage(named: "todoTab")
        case .search:
            return UIImage(named: "searchTab")
        case .group:
            return UIImage(named: "groupTab")
        }
    }
}

final class MainTabCoordinator: NSObject, Coordinator {
        
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    private var tabBarController: UITabBarController
    
    var childCoordinators: [Coordinator] = []
    
    var type: CoordinatorType = .mainTab
    
    private var currentPage: TabBarPage = .calendar
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
    }
    
    func start() {
        let pages = TabBarPage.allCases
        let controllers: [UINavigationController] = pages.map { getTabController($0) }
        self.navigationController.setNavigationBarHidden(true, animated: false)
        prepareTabBarController(withTabControllers: controllers)
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.calendar.rawValue
        
        tabBarController.tabBar.layer.masksToBounds = false
        tabBarController.tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.6
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabBarController.tabBar.layer.shadowRadius = 5
        
        tabBarController.tabBar.barTintColor = .white
        tabBarController.tabBar.isTranslucent = false
        
        self.tabBarController.tabBar.backgroundColor = UIColor(hex: 0xF5F5FB)

        self.tabBarController.tabBar.tintColor = UIColor(hex: 0x000000)
        self.tabBarController.tabBar.unselectedItemTintColor = UIColor(hex: 0xBFC7D7)
        
        navigationController.viewControllers = [tabBarController]
    }
    
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navigation = UINavigationController()
        
        navigation.tabBarItem = UITabBarItem.init(
            title: page.pageTitleValue(),
            image: page.pageTabIcon(),
            tag: page.rawValue
        )

        // 각 코디네이터 생성 후 추가 예정
//        switch page {
//        case .calendar:
//
//        case .todo:
//            <#code#>
//        case .search:
//            <#code#>
//        case .group:
//            <#code#>
//        }
        
        return navigation
    }
}

extension MainTabCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
