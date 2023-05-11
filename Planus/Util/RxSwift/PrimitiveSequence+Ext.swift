//
//  PrimitiveSequence+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/11.
//

import Foundation
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait { //어떤상황이면 어떤 옵저버블을 끼워넣고 다시 재시도 하도록
    func handleRetry<T, E: Error>(retryObservable: Single<T>, errorType: E) -> Single<Element> {
        return retry(when: { (error: Observable<E>) in
            error.flatMap { error -> Single<T> in
                return retryObservable
            }
        })
        .retry(2)
    }
}
