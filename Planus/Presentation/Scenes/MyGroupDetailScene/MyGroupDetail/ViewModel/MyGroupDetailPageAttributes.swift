//
//  MyGroupDetailPageAttributes.swift
//  Planus
//
//  Created by Sangmin Lee on 3/26/24.
//

import Foundation

enum MyGroupDetailPageType: Int {
    case notice = 1
    case calendar = 2
    
    var attributes: [MyGroupDetailPageAttribute] {
        switch self {
        case .notice:
            return [.info, .notice, .member]
        case .calendar:
            return [.info, .calendar]
        }
    }
}

enum MyGroupDetailPageAttribute {
    case info
    case notice
    case member
    case calendar
    
    var sectionIndex: Int {
        switch self {
        case .info:
            return 0
        case .notice:
            return 1
        case .member:
            return 2
        case .calendar:
            return 1
        }
    }
    
    var headerTitle: String? {
        switch self {
        case .notice:
            return "공지사항"
        case .member:
            return "그룹멤버"
        default: return nil
        }
    }
    
    var headerMessage: String? {
        switch self {
        case .notice:
            return "우리 이렇게 진행해요"
        case .member:
            return "우리 이렇게 함께해요"
        default: return nil
        }
    }
}
