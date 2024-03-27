//
//  DefaultFetchImageUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

class DefaultFetchImageUseCase: FetchImageUseCase {
    let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = DefaultImageRepository.shared
    }
    
    func execute(key: String) -> Single<Data> {
        return imageRepository.fetch(key: key)
    }
}
