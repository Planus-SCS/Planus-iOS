//
//  ViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 3/23/24.
//

import Foundation

protocol ViewModel {
    associatedtype UseCases
    associatedtype Actions
    associatedtype Args
    associatedtype Injectable
    
    var useCases: UseCases { get }
    var actions: Actions { get }
    
    init(useCases: UseCases, injectable: Injectable)
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
