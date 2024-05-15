//
//  PrimitiveSequence+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/11.
//

import Foundation
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    
    func handleRetry<T>(retryObservable: Single<T>, errorType: NetworkManagerError) -> Single<Element> {
        return retry(when: { errorObservable in
            errorObservable.flatMap { error -> Single<T> in
                guard let error = error as? NetworkManagerError,
                      error == errorType else {
                    return Single<T>.error(error)
                }
                return retryObservable
            }
        })
    }
    
}

