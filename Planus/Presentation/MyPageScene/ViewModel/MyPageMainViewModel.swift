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
    var name: String?
    var introduce: String?
    lazy var isPushOn: BehaviorSubject<Bool> = {
        // 원래는 유즈케이스에서 바로 가져오자
        return BehaviorSubject<Bool>(value: false)
    }()
    
    var didRefreshUserProfile = BehaviorSubject<Void?>(value: nil)
    var didResigned = PublishSubject<Void>()
    
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
    }
    
    struct Output {
        var didRefreshUserProfile: Observable<Void?>
        var didResigned: Observable<Void>
    }
    
    var updateProfileUseCase: UpdateProfileUseCase
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var removeTokenUseCase: RemoveTokenUseCase
    var removeProfileUseCase: RemoveProfileUseCase
    var fetchImageUseCase: FetchImageUseCase
    
    init(
        updateProfileUseCase: UpdateProfileUseCase,
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        removeTokenUseCase: RemoveTokenUseCase,
        removeProfileUseCase: RemoveProfileUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.updateProfileUseCase = DefaultUpdateProfileUseCase.shared
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.removeTokenUseCase = removeTokenUseCase
        self.removeProfileUseCase = removeProfileUseCase
        self.fetchImageUseCase = fetchImageUseCase
    }
    
    func setProfile(profile: Profile) {
        self.name = profile.nickName
        self.introduce = profile.description
        self.imageURL = profile.imageUrl
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
            .resign
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.resign()
            })
            .disposed(by: bag)
        
        return Output(didRefreshUserProfile: didRefreshUserProfile.asObservable(), didResigned: didResigned.asObservable())
    }
    
    func bindUseCase() {
        updateProfileUseCase
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
        removeTokenUseCase.execute()
    }
    
    func resign() {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.removeProfileUseCase.execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.signOut()
                self?.didResigned.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        return fetchImageUseCase.execute(key: key)
    }

}
