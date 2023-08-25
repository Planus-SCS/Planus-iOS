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
            errorObservable.flatMap { error -> Single<Element> in
                guard let error = error as? NetworkManagerError,
                      error == errorType else {
                    return Single<Element>.create { emmiter -> Disposable in
                        emmiter(.failure(error))
                        return Disposables.create()
                    }
                }
                return retryObservable.flatMap { retrial in
                    return self
                }
            }
        })
    }
    
    
}

extension Observable {
    func handleRetry<T, E: Error>(retryObservable: Observable<T>, errorType: E) -> Observable<Element> {
        return retry(when: { (error: Observable<E>) in
            error.flatMap { error -> Observable<T> in
                return retryObservable
            }
        })
        .retry(2)
    }
}
