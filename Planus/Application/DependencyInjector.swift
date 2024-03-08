//
//  DependencyInjector.swift
//  Planus
//
//  Created by Sangmin Lee on 3/8/24.
//

import Foundation
import Swinject

public typealias Injector = DependencyInjector

public final class DependencyInjector {
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    public func assemble(_ assemblyList: [Assembly]) {
        assemblyList.forEach {
            $0.assemble(container: container)
        }
    }
    
    public func register<T>(_ serviceType: T.Type, _ object: T) {
        container.register(serviceType) { _ in object }
    }
    
    public func resolve<T>(_ serviceType: T.Type) -> T {
        container.resolve(serviceType)!
    }
}

