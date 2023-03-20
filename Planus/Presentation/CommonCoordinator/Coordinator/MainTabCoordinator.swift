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
