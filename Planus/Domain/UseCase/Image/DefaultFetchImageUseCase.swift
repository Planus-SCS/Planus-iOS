//
//  DefaultFetchImageUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

final class DefaultFetchImageUseCase: FetchImageUseCase {
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func execute(key: String) -> Single<Data> {
        return imageRepository.fetch(key: key)
    }
}
