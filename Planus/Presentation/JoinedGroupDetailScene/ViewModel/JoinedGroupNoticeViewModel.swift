//
//  JoinedGroupNoticeViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation

struct JoinedGroupNoticeViewModel {
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
}
