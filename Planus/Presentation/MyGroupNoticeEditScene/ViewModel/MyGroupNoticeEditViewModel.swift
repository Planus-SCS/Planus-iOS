//
//  MyGroupNoticeEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class MyGroupNoticeEditViewModel {
    var bag = DisposeBag()
    
    var goupdId: String?
    var notice = BehaviorSubject<String?>(value: nil)
    var didEditComplete = PublishSubject<Void>()
    
    struct Input {
        var didTapSaveButton: Observable<Void>
        var didChangeNoticeValue: Observable<String?>
    }
    
    struct Output {
        var didInitializedNotice: Observable<String?>
        var didEditCompleted: Observable<Void>
    }
    
    init() {}
    
    func setNotice(groupId: String, notice: String) {
        self.goupdId = groupId
        self.notice.onNext(notice)
    }
    
    func transform(input: Input) -> Output {
        input
            .didTapSaveButton
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.editNotice()
            })
            .disposed(by: bag)
        
        input
            .didChangeNoticeValue
            .bind(to: notice)
            .disposed(by: bag)
        
        return Output(
            didInitializedNotice: notice.compactMap { $0 }.single(),
            didEditCompleted: didEditComplete.asObservable()
        )
    }
    
    func editNotice() {
        
    }
}
