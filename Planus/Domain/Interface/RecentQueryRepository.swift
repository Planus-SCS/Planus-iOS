//
//  RecentQueryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/29.
//

import Foundation
import CoreData

protocol RecentQueryRepository {
    func fetchRecentsQueries() throws -> [RecentSearchQuery]
    func saveRecentsQuery(query: RecentSearchQuery) throws
    func removeQuery(keyword: String) throws
}
