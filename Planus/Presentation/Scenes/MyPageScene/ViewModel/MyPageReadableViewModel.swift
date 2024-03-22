//
//  MyPageReadableViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import Foundation

enum MyPageReadableType: String {
    case notice = "NOTICE"
    case serviceTerms = "SERVICE_TERM"
    case privacyPolicy = "PRIVACY_POLICY"
    
    var title: String {
        switch self {
        case .notice:
            return "공지사항"
        case .serviceTerms:
            return "이용약관"
        case .privacyPolicy:
            return "개인 정보 처리 방침"
        }
    }
    
    var text: String {
        switch self {
        case .notice:
            return "함께하는 코딩 스터디, 참여해보세요!\n코딩 초보를 위한 스터디 그룹, 지금 모집합니다!\n함께 성장하는 코딩 스터디, 참여 신청 바로 받습니다!\n\n스터디 모임은 일주일에 한 번, 정기적으로 진행됩니다.\n\n각 참여자는 매주 주어지는 과제를 해결하고, 그 결과물을 다음 모임에 공유합니다.\n\n참여자끼리의 질문과 답변, 상호 피드백 등을 통해 서로의 실력을 향상시키고, 동기부여를 높입니다.\n\n스터디 모임에서는 주로 프로그래밍 언어, 알고리즘, \n자료구조 등에 대한 학습과 실습을 진행합니다.\n\n참여 신청은 모집글에 댓글로 남겨주시거나, 개설자의 연락처로 문의해주시면 됩니다."
        case .serviceTerms:
            return "함께하는 코딩 스터디, 참여해보세요!\n코딩 초보를 위한 스터디 그룹, 지금 모집합니다!\n함께 성장하는 코딩 스터디, 참여 신청 바로 받습니다!\n\n스터디 모임은 일주일에 한 번, 정기적으로 진행됩니다.\n\n각 참여자는 매주 주어지는 과제를 해결하고, 그 결과물을 다음 모임에 공유합니다.\n\n참여자끼리의 질문과 답변, 상호 피드백 등을 통해 서로의 실력을 향상시키고, 동기부여를 높입니다.\n\n스터디 모임에서는 주로 프로그래밍 언어, 알고리즘, \n자료구조 등에 대한 학습과 실습을 진행합니다.\n\n참여 신청은 모집글에 댓글로 남겨주시거나, 개설자의 연락처로 문의해주시면 됩니다."
        case .privacyPolicy:
            return """
< 플래너스 >('https://www.instagram.com/ready_exion/'이하 'planus')은(는) 「개인정보 보호법」 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.
            
    ○ 이 개인정보처리방침은 2023년 5월 1부터 적용됩니다.


    제1조(개인정보의 처리 목적)

    < 플래너스 >('https://www.instagram.com/ready_exion/'이하 'planus')은(는) 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며 이용 목적이 변경되는 경우에는 「개인정보 보호법」 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

        1. 홈페이지 회원가입 및 관리

        회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지, 각종 고지·통지, 고충처리 목적으로 개인정보를 처리합니다.


        2. 민원사무 처리

        민원인의 신원 확인, 민원사항 확인, 사실조사를 위한 연락·통지, 처리결과 통보 목적으로 개인정보를 처리합니다.


        3. 재화 또는 서비스 제공

        서비스 제공, 콘텐츠 제공을 목적으로 개인정보를 처리합니다.


        4. 마케팅 및 광고에의 활용

        신규 서비스(제품) 개발 및 맞춤 서비스 제공, 서비스의 유효성 확인, 접속빈도 파악 또는 회원의 서비스 이용에 대한 통계 등을 목적으로 개인정보를 처리합니다.




    제2조(개인정보의 처리 및 보유 기간)

    ① < 플래너스 >은(는) 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

    ② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.

        1.<홈페이지 회원가입 및 관리>
        <홈페이지 회원가입 및 관리>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<1년>까지 위 이용목적을 위하여 보유.이용됩니다.
        보유근거 : 관련 법령에 의거하여 보유 기간 동안 보관 후 파기합니다.
        관련법령 : 계약 또는 청약철회 등에 관한 기록 : 5년
        예외사유 :
        2.<민원사무 처리>
        <민원사무 처리>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<1년>까지 위 이용목적을 위하여 보유.이용됩니다.
        보유근거 : 관련 법령에 의거하여 보유 기간 동안 보관 후 파기합니다.
        관련법령 : 소비자의 불만 또는 분쟁처리에 관한 기록 : 3년
        3.<재화 또는 서비스 제공>
        <재화 또는 서비스 제공>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<1년>까지 위 이용목적을 위하여 보유.이용됩니다.
        보유근거 : 관련 법령에 의거하여 보유 기간 동안 보관 후 파기합니다.
        관련법령 : 대금결제 및 재화 등의 공급에 관한 기록 : 5년
        4.<마케팅 및 광고에의 활용>
        <마케팅 및 광고에의 활용>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<1년>까지 위 이용목적을 위하여 보유.이용됩니다.
        보유근거 : 관련 법령에 의거하여 보유 기간 동안 보관 후 파기합니다.
        관련법령 : 계약 또는 청약철회 등에 관한 기록 : 5년


    제3조(처리하는 개인정보의 항목)

    ① < 플래너스 >은(는) 다음의 개인정보 항목을 처리하고 있습니다.

        1< 홈페이지 회원가입 및 관리 >
        필수항목 : 로그인ID, 이메일
        선택항목 :
        2< 민원사무 처리 >
        필수항목 : 로그인ID, 이메일
        선택항목 :
        3< 재화 또는 서비스 제공 >
        필수항목 : 로그인ID, 이메일
        선택항목 :
        4< 마케팅 및 광고에의 활용 >
        필수항목 : 로그인ID, 이메일
        선택항목 :


    제4조(개인정보의 제3자 제공에 관한 사항)

    ① < 플래너스 >은(는) 개인정보를 제1조(개인정보의 처리 목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 「개인정보 보호법」 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.

    ② < 플래너스 >은(는) 다음과 같이 개인정보를 제3자에게 제공하고 있습니다.

        1. < 이용자의 동의가 있거나 다른 법률에 특별한 규정이 있는 경우의 혜택을 받는 자 >
        개인정보를 제공받는 자 : 이용자의 동의가 있거나 다른 법률에 특별한 규정이 있는 경우의 혜택을 받는 자
        제공받는 자의 개인정보 이용목적 : 로그인ID, 이메일
        제공받는 자의 보유.이용기간: 1년


    제5조(개인정보의 파기절차 및 파기방법)


    ① < 플래너스 > 은(는) 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.

    ② 정보주체로부터 동의받은 개인정보 보유기간이 경과하거나 처리목적이 달성되었음에도 불구하고 다른 법령에 따라 개인정보를 계속 보존하여야 하는 경우에는, 해당 개인정보를 별도의 데이터베이스(DB)로 옮기거나 보관장소를 달리하여 보존합니다.
        1. 법령 근거 :
        2. 보존하는 개인정보 항목 : 계좌정보, 거래날짜

    ③ 개인정보 파기의 절차 및 방법은 다음과 같습니다.
        1. 파기절차
        < 플래너스 > 은(는) 파기 사유가 발생한 개인정보를 선정하고, < 플래너스 > 의 개인정보 보호책임자의 승인을 받아 개인정보를 파기합니다.

        2. 파기방법

        전자적 파일 형태의 정보는 기록을 재생할 수 없는 기술적 방법을 사용합니다



    제6조(정보주체와 법정대리인의 권리·의무 및 그 행사방법에 관한 사항)



    ① 정보주체는 플래너스에 대해 언제든지 개인정보 열람·정정·삭제·처리정지 요구 등의 권리를 행사할 수 있습니다.

    ② 제1항에 따른 권리 행사는플래너스에 대해 「개인정보 보호법」 시행령 제41조제1항에 따라 서면, 전자우편, 모사전송(FAX) 등을 통하여 하실 수 있으며 플래너스은(는) 이에 대해 지체 없이 조치하겠습니다.

    ③ 제1항에 따른 권리 행사는 정보주체의 법정대리인이나 위임을 받은 자 등 대리인을 통하여 하실 수 있습니다.이 경우 “개인정보 처리 방법에 관한 고시(제2020-7호)” 별지 제11호 서식에 따른 위임장을 제출하셔야 합니다.

    ④ 개인정보 열람 및 처리정지 요구는 「개인정보 보호법」 제35조 제4항, 제37조 제2항에 의하여 정보주체의 권리가 제한 될 수 있습니다.

    ⑤ 개인정보의 정정 및 삭제 요구는 다른 법령에서 그 개인정보가 수집 대상으로 명시되어 있는 경우에는 그 삭제를 요구할 수 없습니다.

    ⑥ 플래너스은(는) 정보주체 권리에 따른 열람의 요구, 정정·삭제의 요구, 처리정지의 요구 시 열람 등 요구를 한 자가 본인이거나 정당한 대리인인지를 확인합니다.



    제7조(개인정보의 안전성 확보조치에 관한 사항)

    < 플래너스 >은(는) 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.

        1. 내부관리계획의 수립 및 시행
        개인정보의 안전한 처리를 위하여 내부관리계획을 수립하고 시행하고 있습니다.

        2. 개인정보 취급 직원의 최소화 및 교육
        개인정보를 취급하는 직원을 지정하고 담당자에 한정시켜 최소화 하여 개인정보를 관리하는 대책을 시행하고 있습니다.

        3. 정기적인 자체 감사 실시
        개인정보 취급 관련 안정성 확보를 위해 정기적(분기 1회)으로 자체 감사를 실시하고 있습니다.

        4. 개인정보에 대한 접근 제한
        개인정보를 처리하는 데이터베이스시스템에 대한 접근권한의 부여,변경,말소를 통하여 개인정보에 대한 접근통제를 위하여 필요한 조치를 하고 있으며 침입차단시스템을 이용하여 외부로부터의 무단 접근을 통제하고 있습니다.

        5. 접속기록의 보관 및 위변조 방지
        개인정보처리시스템에 접속한 기록을 최소 1년 이상 보관, 관리하고 있으며,다만, 5만명 이상의 정보주체에 관하여 개인정보를 추가하거나, 고유식별정보 또는 민감정보를 처리하는 경우에는 2년이상 보관, 관리하고 있습니다.
        또한, 접속기록이 위변조 및 도난, 분실되지 않도록 보안기능을 사용하고 있습니다.

        6. 개인정보의 암호화
        이용자의 개인정보는 비밀번호는 암호화 되어 저장 및 관리되고 있어, 본인만이 알 수 있으며 중요한 데이터는 파일 및 전송 데이터를 암호화 하거나 파일 잠금 기능을 사용하는 등의 별도 보안기능을 사용하고 있습니다.

        7. 해킹 등에 대비한 기술적 대책
        <플래너스>('planus')은 해킹이나 컴퓨터 바이러스 등에 의한 개인정보 유출 및 훼손을 막기 위하여 보안프로그램을 설치하고 주기적인 갱신·점검을 하며 외부로부터 접근이 통제된 구역에 시스템을 설치하고 기술적/물리적으로 감시 및 차단하고 있습니다.

        8. 비인가자에 대한 출입 통제
        개인정보를 보관하고 있는 물리적 보관 장소를 별도로 두고 이에 대해 출입통제 절차를 수립, 운영하고 있습니다.

        9. 문서보안을 위한 잠금장치 사용
        개인정보가 포함된 서류, 보조저장매체 등을 잠금장치가 있는 안전한 장소에 보관하고 있습니다.




    제8조(개인정보를 자동으로 수집하는 장치의 설치·운영 및 그 거부에 관한 사항)



    플래너스 은(는) 정보주체의 이용정보를 저장하고 수시로 불러오는 ‘쿠키(cookie)’를 사용하지 않습니다.


    제9조(추가적인 이용·제공 판단기준)

    < 플래너스 > 은(는) ｢개인정보 보호법｣ 제15조제3항 및 제17조제4항에 따라 ｢개인정보 보호법 시행령｣ 제14조의2에 따른 사항을 고려하여 정보주체의 동의 없이 개인정보를 추가적으로 이용·제공할 수 있습니다. 이에 따라 < 플래너스 > 가(이) 정보주체의 동의 없이 추가적인 이용·제공을 하기 위해서 다음과 같은 사항을 고려하였습니다.
        ▶ 개인정보를 추가적으로 이용·제공하려는 목적이 당초 수집 목적과 관련성이 있는지 여부

        ▶ 개인정보를 수집한 정황 또는 처리 관행에 비추어 볼 때 추가적인 이용·제공에 대한 예측 가능성이 있는지 여부

        ▶ 개인정보의 추가적인 이용·제공이 정보주체의 이익을 부당하게 침해하는지 여부

        ▶ 가명처리 또는 암호화 등 안전성 확보에 필요한 조치를 하였는지 여부

        ※ 추가적인 이용·제공 시 고려사항에 대한 판단기준은 사업자/단체 스스로 자율적으로 판단하여 작성·공개함



    제10조(가명정보를 처리하는 경우 가명정보 처리에 관한 사항)

    < 플래너스 > 은(는) 다음과 같은 목적으로 가명정보를 처리하고 있습니다.

        ▶ 가명정보의 처리 목적

        - 직접작성 가능합니다.

        ▶ 가명정보의 처리 및 보유기간

        - 직접작성 가능합니다.

        ▶ 가명정보의 제3자 제공에 관한 사항(해당되는 경우에만 작성)

        - 직접작성 가능합니다.

        ▶ 가명정보 처리의 위탁에 관한 사항(해당되는 경우에만 작성)

        - 직접작성 가능합니다.

        ▶ 가명처리하는 개인정보의 항목

        - 직접작성 가능합니다.

        ▶ 법 제28조의4(가명정보에 대한 안전조치 의무 등)에 따른 가명정보의 안전성 확보조치에 관한 사항

        - 직접작성 가능합니다.

    제11조 (개인정보 보호책임자에 관한 사항)

    ① 플래너스 은(는) 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.

        ▶ 개인정보 보호책임자
        성명 :양세연
        직책 :팀원
        직급 :팀원
        연락처 :+821053938214, county10@naver.com,
        ※ 개인정보 보호 담당부서로 연결됩니다.


        ▶ 개인정보 보호 담당부서
        부서명 :
        담당자 :
        연락처 :, ,
    ② 정보주체께서는 플래너스 의 서비스(또는 사업)을 이용하시면서 발생한 모든 개인정보 보호 관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자 및 담당부서로 문의하실 수 있습니다. 플래너스 은(는) 정보주체의 문의에 대해 지체 없이 답변 및 처리해드릴 것입니다.

    제12조(개인정보의 열람청구를 접수·처리하는 부서)
    정보주체는 ｢개인정보 보호법｣ 제35조에 따른 개인정보의 열람 청구를 아래의 부서에 할 수 있습니다.
    < 플래너스 >은(는) 정보주체의 개인정보 열람청구가 신속하게 처리되도록 노력하겠습니다.

        ▶ 개인정보 열람청구 접수·처리 부서
        부서명 :
        담당자 :
        연락처 : , ,


    제13조(정보주체의 권익침해에 대한 구제방법)



    정보주체는 개인정보침해로 인한 구제를 받기 위하여 개인정보분쟁조정위원회, 한국인터넷진흥원 개인정보침해신고센터 등에 분쟁해결이나 상담 등을 신청할 수 있습니다. 이 밖에 기타 개인정보침해의 신고, 상담에 대하여는 아래의 기관에 문의하시기 바랍니다.

        1. 개인정보분쟁조정위원회 : (국번없이) 1833-6972 (www.kopico.go.kr)
        2. 개인정보침해신고센터 : (국번없이) 118 (privacy.kisa.or.kr)
        3. 대검찰청 : (국번없이) 1301 (www.spo.go.kr)
        4. 경찰청 : (국번없이) 182 (ecrm.cyber.go.kr)

        「개인정보보호법」제35조(개인정보의 열람), 제36조(개인정보의 정정·삭제), 제37조(개인정보의 처리정지 등)의 규정에 의한 요구에 대 하여 공공기관의 장이 행한 처분 또는 부작위로 인하여 권리 또는 이익의 침해를 받은 자는 행정심판법이 정하는 바에 따라 행정심판을 청구할 수 있습니다.

        ※ 행정심판에 대해 자세한 사항은 중앙행정심판위원회(www.simpan.go.kr) 홈페이지를 참고하시기 바랍니다.

    제14조(개인정보 처리방침 변경)


    ① 이 개인정보처리방침은 2023년 5월 1부터 적용됩니다.

    ② 이전의 개인정보 처리방침은 아래에서 확인하실 수 있습니다.

    예시 ) - 20XX. X. X ~ 20XX. X. X 적용 (클릭)

    예시 ) - 20XX. X. X ~ 20XX. X. X 적용 (클릭)

    예시 ) - 20XX. X. X ~ 20XX. X. X 적용 (클릭)
"""
        }
    }
}

final class MyPageReadableViewModel: ViewModel {
    struct UseCases {}
    
    struct Actions {
        var goBack: (() -> Void)?
    }
    
    struct Args {
        let type: MyPageReadableType
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    let useCases: UseCases
    let actions: Actions
    
    var navigationTitle: String?
    var text: String?
    
    struct Input {}
    
    struct Output {
        var navigationTitle: String?
        var text: String?
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.text = injectable.args.type.text
        self.navigationTitle = injectable.args.type.title
        self.actions = injectable.actions
    }
    
    func transform(input: Input) -> Output {
        return Output(navigationTitle: navigationTitle, text: text)
    }
}
