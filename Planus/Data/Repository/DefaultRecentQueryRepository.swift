//
//  DefaultRecentSearchRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/29.
//

import Foundation
import CoreData

final class DefaultRecentQueryRepository: RecentQueryRepository {
    
    let maxStorageLimit: Int = 20
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RecentSearch")
        container.loadPersistentStores(completionHandler: { (storeDesc, error) in
            if let error = error {
                fatalError("Unsolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    func fetchRecentsQueries() throws -> [RecentSearchQuery] {
        let context = persistentContainer.viewContext
        
        let request = RecentSearchKeyword.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(RecentSearchKeyword.date), ascending: false)]
        request.fetchLimit = maxStorageLimit
        
        return try context.fetch(request).map { $0.toDomain() }
    }
    
    func saveRecentsQuery(query: RecentSearchQuery) throws {
        let context = persistentContainer.viewContext
        try cleanUpQueries(for: query)
        
        guard let entity = NSEntityDescription.entity(forEntityName: "RecentSearchKeyword", in: context),
              let recentQuery = NSManagedObject(entity: entity, insertInto: context) as? RecentSearchKeyword else { return }

        recentQuery.keyword = query.keyword
        recentQuery.date = query.date
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
            
        }
    }
    
    func removeQuery(keyword: String) throws {
        let context = persistentContainer.viewContext
        
        let request = RecentSearchKeyword.fetchRequest()
        
        let result = try context.fetch(request)
        result.filter({ $0.keyword == keyword }).forEach { context.delete($0) }
        try context.save()
    }
    
    func removeAllQueries() throws {
        let context = persistentContainer.viewContext
        
        let request = RecentSearchKeyword.fetchRequest()
        
        let result = try context.fetch(request)
        result.forEach { context.delete($0) }
        try context.save()
    }
    
    func cleanUpQueries(for query: RecentSearchQuery) throws {
        let context = persistentContainer.viewContext
        
        let request = RecentSearchKeyword.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(RecentSearchKeyword.date), ascending: false)]
        
        var result = try context.fetch(request)
        
        removeDuplicates(for: query, in: &result)
        removeQueries(limit: maxStorageLimit, in: result)
    }
    
    private func removeDuplicates(
        for query: RecentSearchQuery,
        in queries: inout [RecentSearchKeyword]
    ) {
        let context = persistentContainer.viewContext
        queries
            .filter { $0.keyword == query.keyword }
            .forEach { context.delete($0) }
        queries.removeAll { $0.keyword == query.keyword }
    }

    private func removeQueries(
        limit: Int,
        in queries: [RecentSearchKeyword]
    ) {
        let context = persistentContainer.viewContext
        guard queries.count > limit else { return }

        queries.suffix(queries.count - limit)
            .forEach { context.delete($0) }
    }
}
