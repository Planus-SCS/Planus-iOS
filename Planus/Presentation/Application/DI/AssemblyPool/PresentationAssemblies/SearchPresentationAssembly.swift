//
//  SearchAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class SearchPresentationAssembly: Assembly {
    func assemble(container: Container) {
        assembleSearchHome(container: container)
        assembleSearchResult(container: container)
    }
    
    func assembleSearchHome(container: Container) {
        container.register(SearchHomeViewModel.self) { (r, injectable: SearchHomeViewModel.Injectable) in
            return SearchHomeViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchSearchHomeUseCase: r.resolve(FetchSearchHomeUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
    
    func assembleSearchResult(container: Container) {
        container.register(SearchResultViewModel.self) { (r, injectable: SearchResultViewModel.Injectable) in
            return SearchResultViewModel(
                useCases: .init(
                    recentQueryRepository: r.resolve(RecentQueryRepository.self)!,
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchSearchResultUseCase: r.resolve(FetchSearchResultUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
}
