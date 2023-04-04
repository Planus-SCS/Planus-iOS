//
//  JoinedGroupDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import Foundation
import RxSwift

struct JoinedGroupDetailViewModelActions {
    var pop: (() -> Void)?
}

class JoinedGroupDetailViewModel {
    var bag = DisposeBag()
    var actions: JoinedGroupDetailViewModelActions?
    
    var mainDayList = [DayViewModel]()
    
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    var groupTitle: String? = "가보자네카라쿠베베"
    var tag: String? = "#태그개수수수수 #네개까지지지지 #제한하는거다다\n#어때아무글자텍스트테스트 #오개까지아무글자텍스"
    var memberCount: String? = "1/4"
    var captin: String? = "기정이짱짱"
    var notice: String? = """
함께하는 코딩 스터디, 참여해보세요!
코딩 초보를 위한 스터디 그룹, 지금 모집합니다!
함께 성장하는 코딩 스터디, 참여 신청 바로 받습니다!

스터디 모임은 일주일에 한 번, 정기적으로 진행됩니다.

각 참여자는 매주 주어지는 과제를 해결하고, 그 결과물을 다음 모임에 공유합니다.

참여자끼리의 질문과 답변, 상호 피드백 등을 통해 서로의 실력을 향상시키고, 동기부여를 높입니다.

스터디 모임에서는 주로 프로그래밍 언어, 알고리즘, 자료구조 등에 대한 학습과 실습을 진행합니다.

참여 신청은 모집글에 댓글로 남겨주시거나, 개설자의 연락처로 문의해주시면 됩니다.
"""
    var memberList: [Member]? = [
        Member(imageName: "member1", name: "기정이짱짱", isCap: true, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member2", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member3", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member4", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member5", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member6", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member7", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member8", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member9", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member10", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member11", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member12", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member13", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개")
    ]
    
    struct Input {
    }
    
    struct Output {
    }
    
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let fetchTodoListUseCase: FetchTodoListUseCase
    
    init(
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchTodoListUseCase: FetchTodoListUseCase
    ) {
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchTodoListUseCase = fetchTodoListUseCase
        test()
    }
    
    func test() {
        self.mainDayList = createMonthlyCalendarUseCase.execute(date: Date())
        print(self.mainDayList)
    }
    
    func setActions(actions: JoinedGroupDetailViewModelActions) {
        self.actions = actions
    }
    
//    func transform(input: Input) -> Output {
//        input
//            .didTappedJoinBtn
//            .withUnretained(self)
//            .subscribe(onNext: { vm, _ in
//                vm.requestJoinGroup(id: "abc")
//            })
//            .disposed(by: bag)
//
//        input
//            .didTappedBackBtn
//            .withUnretained(self)
//            .subscribe(onNext: { vm, _ in
//                vm.actions?.popCurrentPage?()
//            })
//            .disposed(by: bag)
//
//        return Output(didGroupInfoFetched: didGroupInfoFetched.asObservable())
//    }
//
//    func fetchGroupInfo(id: String) {
//        didGroupInfoFetched.onNext(())
//    }
//
//    func requestJoinGroup(id: String) {
//        /*
//         뭔가 요청을 하고
//         */
//        actions?.popCurrentPage?()
//    }
}
