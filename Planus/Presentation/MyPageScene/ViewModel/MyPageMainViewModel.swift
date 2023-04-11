//
//  MyPageMainViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import Foundation
import RxSwift

class MyPageMainViewModel {
    var bag = DisposeBag()
    
    var imageURL: String?
    var name: String? = "오수"
    var introduce: String? = "오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!! 오수생이라고 무시하지 마라!!"
    lazy var isPushOn: BehaviorSubject<Bool> = {
        // 원래는 유즈케이스에서 바로 가져오자
        return BehaviorSubject<Bool>(value: false)
    }()
    
    var didFetchUserProfile = BehaviorSubject<Void?>(value: nil)
    
    lazy var titleList: [MyPageMainTitleViewModel] = [ //이 리스트까지 이넘으로 해서 caseIterable쓸까?
        MyPageMainTitleViewModel(title: "푸시 알림 설정", type: .toggle(self.isPushOn)),
        MyPageMainTitleViewModel(title: "공지 사항", type: .normal),
        MyPageMainTitleViewModel(title: "문의하기", type: .normal),
        MyPageMainTitleViewModel(title: "이용 약관", type: .normal),
        MyPageMainTitleViewModel(title: "개인 정보 처리 방침", type: .normal),
        MyPageMainTitleViewModel(title: "로그아웃", type: .normal),
        MyPageMainTitleViewModel(title: "회원 탈퇴", type: .normal)
    ]
    
    struct Input {
        var didSelectedAt: Observable<Int>
    }
    
    struct Output {
        var didFetchUserProfile: Observable<Void?>
    }
    
    init() {
        /*
         멤버 프로필만 가져오는 유즈케이스,
         푸시에 대한 정보 가져올 유즈케이스 필요함
         */

    }
    
    func transform(input: Input) -> Output {
        input
            .didSelectedAt
            .subscribe(onNext: { index in

            })
            .disposed(by: bag)
        
        return Output(didFetchUserProfile: didFetchUserProfile.asObservable())
    }
    
    func fetchUserProfile() {
        
    }

}
