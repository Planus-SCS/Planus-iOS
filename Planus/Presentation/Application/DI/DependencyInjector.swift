//
//  DependencyInjector.swift
//  Planus
//
//  Created by Sangmin Lee on 3/8/24.
//

import Foundation
import Swinject
import UIKit

public typealias Injector = DependencyInjector

public final class DependencyInjector {
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func assemble(_ assemblyList: [Assembly]) {
        assemblyList.forEach {
            $0.assemble(container: container)
        }
    }
    
    func register<T>(_ serviceType: T.Type, _ object: T) {
        container.register(serviceType) { _ in object }
    }
    
    func resolve<T>(_ serviceType: T.Type) -> T {
        container.resolve(serviceType)!
    }
    
    func resolve<T: ViewModelable>(_ viewModelType: T.Type, injectable: T.Injectable) -> T {
        container.resolve(viewModelType, argument: injectable)!
    }
}
