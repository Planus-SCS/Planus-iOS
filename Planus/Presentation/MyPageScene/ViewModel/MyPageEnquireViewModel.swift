//
//  MyPageEnquireViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import Foundation
import RxSwift

class MyPageEnquireViewModel {
    var bag = DisposeBag()
    
    var inquireText = BehaviorSubject<String?>(value: nil)
    var didEditComplete = PublishSubject<Void>()
    
    struct Input {
        var didTapSendButton: Observable<Void>
        var didChangeInquireValue: Observable<String?>
    }
    
    struct Output {
        var didEditCompleted: Observable<Void>
    }
    
    init() {}
    
    func transform(input: Input) -> Output {
        input
            .didTapSendButton
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.sendInquire()
            })
            .disposed(by: bag)
        
        input
            .didChangeInquireValue
            .bind(to: inquireText)
            .disposed(by: bag)
        
        return Output(
            didEditCompleted: didEditComplete.asObservable()
        )
    }
    
    func sendInquire() {
        
    }
}
