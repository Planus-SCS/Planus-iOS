//
//  MyPageMainViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import Foundation
import RxSwift
import AuthenticationServices

class MyPageMainViewModel: ViewModel {
    struct UseCases {
        let updateProfileUseCase: UpdateProfileUseCase
        let getTokenUseCase: GetTokenUseCase
        let refreshTokenUseCase: RefreshTokenUseCase
        let removeTokenUseCase: RemoveTokenUseCase
        let removeProfileUseCase: RemoveProfileUseCase
        let fetchImageUseCase: FetchImageUseCase
        let getSignedInSNSTypeUseCase: GetSignedInSNSTypeUseCase
        let convertToSha256UseCase: ConvertToSha256UseCase
        let revokeAppleTokenUseCase: RevokeAppleTokenUseCase
    }
    
    struct Actions {
    }
    
    struct Args {
        let profile: Profile
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    let useCases: UseCases
    let actions: Actions
    
    var bag = DisposeBag()
    
    var imageURL: String?
    var name: String?
    var introduce: String?
    lazy var isPushOn: BehaviorSubject<Bool> = {
        // 원래는 유즈케이스에서 바로 가져오자
        return BehaviorSubject<Bool>(value: false)
    }()
    
    var didRefreshUserProfile = BehaviorSubject<Void?>(value: nil)
    var didResigned = PublishSubject<Void>()
    var didRequireAppleSignInWithRequest = PublishSubject<ASAuthorizationAppleIDRequest>()
    var nowResigning: Bool = false
    
    lazy var titleList: [MyPageMainTitleViewModel] = [ //이 리스트까지 이넘으로 해서 caseIterable쓸까?
//        MyPageMainTitleViewModel(title: "푸시 알림 ~ 🚧 개발중 👷‍♂️", type: .toggle(self.isPushOn)),
//        MyPageMainTitleViewModel(title: "공지 사항", type: .normal),
//        MyPageMainTitleViewModel(title: "문의하기", type: .normal),
//        MyPageMainTitleViewModel(title: "이용 약관", type: .normal),
//        MyPageMainTitleViewModel(title: "개인 정보 처리 방침", type: .normal),
        MyPageMainTitleViewModel(title: "로그아웃", type: .normal),
        MyPageMainTitleViewModel(title: "회원 탈퇴", type: .normal)
    ]
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didSelectedAt: Observable<Int>
        var signOut: Observable<Void>
        var resign: Observable<Void>
        var didReceiveAppleAuthCode: Observable<Data>
    }
    
    struct Output {
        var didRefreshUserProfile: Observable<Void?>
        var didResigned: Observable<Void>
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
            .didSelectedAt
            .subscribe(onNext: { index in

            })
            .disposed(by: bag)
        
        input
            .signOut
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.signOut()
                vm.didResigned.onNext(())
            })
            .disposed(by: bag)
        
        input
            .resign
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.resignTapped()
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
        
        return Output(
            didRefreshUserProfile: didRefreshUserProfile.asObservable(),
            didResigned: didResigned.asObservable(),
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
        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.removeProfileUseCase.execute(token: token)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.signOut()
                self?.nowResigning = false
                self?.didResigned.onNext(())
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
        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else { throw DefaultError.noCapturedSelf }
                return self.useCases.revokeAppleTokenUseCase
                    .execute(token: token, authorizationCode: code)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.resign()
            }, onFailure: { [weak self] error in
                self?.nowResigning = false
            })
            .disposed(by: bag)
    }
}
