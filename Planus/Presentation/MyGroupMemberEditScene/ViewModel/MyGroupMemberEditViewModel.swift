//
//  MyGroupMemberEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class MyGroupMemberEditViewModel {
    
    var bag = DisposeBag()
    
    var memberList: [Member]? = [
        Member(imageName: "", name: "기정이짱짱", isCap: true, desc: "자기소개자기소개자기소개자기소개자기소개자기"),
        Member(imageName: "", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기"),
        Member(imageName: "", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기"),
        Member(imageName: "", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기")
    ]
    
    struct Input {
        var didTappedResignButton: Observable<String>
    }
    
    struct Output {
        var didRequestResign: Observable<Void>
        var didResignedAt: Observable<Int>
    }
    
    var resignRequested = PublishSubject<Void>() //요청 응답 올때까지 인디케이터 보여주기?
    var resignedAt = PublishSubject<Int>()
    
    init() {}
    
    func transform(input: Input) -> Output {
        input
            .didTappedResignButton
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                vm.resignMember(id: id)
            })
            .disposed(by: bag)
        
        return Output(
            didRequestResign: resignRequested.asObservable(),
            didResignedAt: resignedAt.asObservable()
        )
    }
    
    func setMemberList(memberList: [Member]) {
        self.memberList = memberList
    }
    
    func resignMember(id: String) {
        resignRequested.onNext(())
        guard let index = memberList?.firstIndex(where: { $0.name == id }) else { return }
        memberList?.remove(at: index)
        resignedAt.onNext(index)
    }
    
}
