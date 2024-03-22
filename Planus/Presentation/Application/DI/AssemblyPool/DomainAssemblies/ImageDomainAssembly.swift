//
//  DomainAssembly+Image.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

class ImageDomainAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(FetchImageUseCase.self) { r in
            let imageRepo = r.resolve(ImageRepository.self)!
            return DefaultFetchImageUseCase(imageRepository: imageRepo)
        }
    }
    
}
