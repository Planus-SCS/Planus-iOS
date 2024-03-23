//
//  MyPageMainViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import Foundation
import RxSwift
import AuthenticationServices

enum MyPageMenuType: Int, CaseIterable {
    case serviceTerms = 0
    case privacyPolicy
    case signOut
    case withDraw
    
    var title: String {
        switch self {
        case .serviceTerms:
            "이용 약관"
        case .privacyPolicy:
            "개인 정보 처리 방침"
        case .signOut:
            "로그아웃"
        case .withDraw:
            "회원 탈퇴"
        }
    }
}

final class MyPageMainViewModel: ViewModel {
    struct UseCases {
        let updateProfileUseCase: UpdateProfileUseCase
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let removeTokenUseCase: RemoveTokenUseCase
        let removeProfileUseCase: RemoveProfileUseCase
        let fetchImageUseCase: FetchImageUseCase
        let getSignedInSNSTypeUseCase: GetSignedInSNSTypeUseCase
        let convertToSha256UseCase: ConvertToSha256UseCase
        let revokeAppleTokenUseCase: RevokeAppleTokenUseCase
    }
    
    struct Actions {
        var editProfile: (() -> Void)?
        var showTermsOfUse: (() -> Void)?
        var showPrivacyPolicy: (() -> Void)?
        var backToSignIn: (() -> Void)?
        var pop: (() -> Void)?
        var finish: (() -> Void)?
    }
    
    struct Args {
        let profile: Profile
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    let useCases: UseCases
    var actions: Actions
    
    var bag = DisposeBag()
    
    var imageURL: String?
    var name: String?
    var introduce: String?

    
    
    var didRefreshUserProfile = BehaviorSubject<Void?>(value: nil)
    var showPopUp = PublishSubject<(title: String, message: String, alertAttrs: [CustomAlertAttr])>()
    var didRequireAppleSignInWithRequest = PublishSubject<ASAuthorizationAppleIDRequest>()
    var nowResigning: Bool = false
    
    let titleList = MyPageMenuType.allCases
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var editBtnTapped: Observable<Void>
        var didSelectedAt: Observable<Int>
        var didReceiveAppleAuthCode: Observable<Data>
        var backBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didRefreshUserProfile: Observable<Void?>
        var showPopUp: Observable<(title: String, message: String, alertAttrs: [CustomAlertAttr])>
        var didRequireAppleSignInWithRequest: Observable<ASAuthorizationAppleIDRequest>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.name = injectable.args.profile.nickName
        self.introduce = injectable.args.profile.description
        self.imageURL = injectable.args.profile.imageUrl
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.bindUseCase()
            })
            .disposed(by: bag)
        
        input
            .editBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.editProfile?()
            })
            .disposed(by: bag)
        
        input
            .didSelectedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, item in
                guard let type = MyPageMenuType(rawValue: item) else { return }
                vm.routeMenu(type: type)
            })
            .disposed(by: bag)
        
        input
            .didReceiveAppleAuthCode
            .withUnretained(self)
            .subscribe(onNext: { vm, authData in
                guard let authCodeStr = String(data: authData, encoding: .utf8) else { return }
                vm.revokeAppleToken(code: authCodeStr)
            })
            .disposed(by: bag)
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        return Output(
            didRefreshUserProfile: didRefreshUserProfile.asObservable(),
            showPopUp: showPopUp.asObservable(),
            didRequireAppleSignInWithRequest: didRequireAppleSignInWithRequest.asObservable()
        )
    }
    
    func bindUseCase() {
        useCases.updateProfileUseCase
            .didUpdateProfile
            .withUnretained(self)
            .subscribe(onNext: { vm, profile in
                vm.name = profile.nickName
                vm.introduce = profile.description
                vm.imageURL = profile.imageUrl
                vm.didRefreshUserProfile.onNext(())
            })
            .disposed(by: bag)
    }
    
    func routeMenu(type: MyPageMenuType) {
        switch type {
        case .serviceTerms:
            actions.showTermsOfUse?()
        case .privacyPolicy:
            actions.showPrivacyPolicy?()
        case .signOut:
            showPopUp.onNext((
                title: "로그아웃",
                message: "로그아웃 합니다.",
                alertAttrs: [
                    CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
                    CustomAlertAttr(title: "로그아웃", actionHandler: { [weak self] in
                        self?.signOut()
                        self?.actions.backToSignIn?()
                    }, type: .warning)
                ]
            ))
        case .withDraw:
            showPopUp.onNext((
                title: "회원 탈퇴",
                message: "플래너스를 탈퇴 합니다",
                alertAttrs: [
                    CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
                    CustomAlertAttr(title: "탈퇴", actionHandler: { [weak self] in
                        self?.showPopUp.onNext((
                            title: "회원 탈퇴",
                            message: "회원 탈퇴를 진행하게 되면 모든 정보가 손실되요 😥",
                            alertAttrs: [
                                CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
                                CustomAlertAttr(title: "탈퇴", actionHandler: {
                                    self?.resignTapped()
                                }, type: .warning)
                            ]
                        ))
                    }, type: .warning)
                ]
            ))
        }
    }
    
    func signOut() {
        useCases.removeTokenUseCase.execute()
    }
    
    func resignTapped() {
        nowResigning = true
        guard let authType = useCases.getSignedInSNSTypeUseCase.execute() else { return }
        
        switch authType {
        case .kakao, .google:
            resign()
        case .apple:
            let request = generateAppleSignInRequest()
            didRequireAppleSignInWithRequest.onNext(request)
        }
    }
    
    func resign() {
        guard nowResigning else { return }
        
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self!.useCases.removeProfileUseCase.execute(token: token)
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.signOut()
                self?.nowResigning = false
                self?.actions.backToSignIn?()
            }, onFailure: { [weak self] error in
                self?.nowResigning = false
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        return useCases.fetchImageUseCase.execute(key: key)
    }
    
    func generateAppleSignInRequest() -> ASAuthorizationAppleIDRequest {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = useCases.convertToSha256UseCase.execute(AppleSignInNonce.nonce)
        return request
    }

    func revokeAppleToken(code: String) {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.revokeAppleTokenUseCase
                    .execute(token: token, authorizationCode: code)
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.resign()
            }, onFailure: { [weak self] error in
                self?.nowResigning = false
            })
            .disposed(by: bag)
    }
}
