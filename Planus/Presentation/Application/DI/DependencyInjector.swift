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
    
    func resolve<T, Arg>(_ serviceType: T.Type, argument: Arg) -> T {
        container.resolve(serviceType, argument: argument)!
    }
    
    func resolve<T, Arg>(_ serviceType: T.Type, name: String, argument: Arg) -> T {
        container.resolve(serviceType, name: name, argument: argument)!
    }
    
    func resolve<T: ViewModel>(_ viewModelType: T.Type, injectable: T.Injectable) -> T {
        container.resolve(viewModelType, argument: injectable)!
    }
}
