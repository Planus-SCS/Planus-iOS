//
//  Coordinator.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

enum CoordinatorType {
    case app, 
         mainTab,
         signIn,
         homeCalendar,
         myDailyCalendar, groupDailyCalendar, memberDailyCalendar,
         myTodoDetail, groupTodoDetail, memberTodoDetail,
         search,
         myGroupList,
         groupIntroduce,
         groupCreate,
         myGroupDetail,
         socialDailyCalendar,
         memberProfile,
         notification
}

protocol Coordinator: AnyObject {
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    var childCoordinators: [Coordinator] { get set }
    var type: CoordinatorType { get }
    
    func finish()
}

extension Coordinator {
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: Coordinator)
}
