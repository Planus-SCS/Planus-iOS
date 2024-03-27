//
//  RecentSearchKeyword+CoreDataProperties.swift
//  
//
//  Created by Sangmin Lee on 2023/05/29.
//
//

import Foundation
import CoreData


extension RecentSearchKeyword {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentSearchKeyword> {
        return NSFetchRequest<RecentSearchKeyword>(entityName: "RecentSearchKeyword")
    }

    @NSManaged public var date: Date?
    @NSManaged public var keyword: String?

}

extension RecentSearchKeyword {
    func toDomain() -> RecentSearchQuery {
        return RecentSearchQuery(date: date, keyword: keyword)
    }
}
