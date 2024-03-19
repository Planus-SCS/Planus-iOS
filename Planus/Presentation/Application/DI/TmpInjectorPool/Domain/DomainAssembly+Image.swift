//
//  DomainAssembly+Image.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleImage(container: Container) {
        container.register(FetchImageUseCase.self) { r in
            let imageRepo = r.resolve(ImageRepository.self)!
            return DefaultFetchImageUseCase(imageRepository: imageRepo)
        }
    }
    
}
