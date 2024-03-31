//
//  PrimitiveSequence+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/11.
//

import Foundation
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait { //어떤상황이면 어떤 옵저버블을 끼워넣고 다시 재시도 하도록
    
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

