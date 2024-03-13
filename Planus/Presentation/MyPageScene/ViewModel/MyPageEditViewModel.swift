//
//  MyPageEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

class MyPageEditViewModel: ViewModel {
    struct UseCases {
        var getTokenUseCase: GetTokenUseCase
        var refreshTokenUseCase: RefreshTokenUseCase
        var readProfileUseCase: ReadProfileUseCase
        var updateProfileUseCase: UpdateProfileUseCase
        var fetchImageUseCase: FetchImageUseCase
    }
    
    struct Actions {
        
    }
    
    struct Args {}
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    let useCases: UseCases
    let actions: Actions
    
    var bag = DisposeBag()
    
    var name = BehaviorSubject<String?>(value: nil)
    var introduce = BehaviorSubject<String?>(value: nil)
    var profileImage = BehaviorSubject<ImageFile?>(value: nil)
    
    var imageChangeChecker: Bool = false
    var isInitialValueNil: Bool = false
    
    var didUpdateProfile = PublishSubject<Void>()
    var showMessage = PublishSubject<Message>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didChangeName: Observable<String?>
        var didChangeIntroduce: Observable<String?>
        var didChangeImage: Observable<ImageFile?>
        var saveBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didFetchName: Observable<String?>
        var didFetchIntroduce: Observable<String?>
        var didFetchImage: Observable<Data?>
        var saveBtnEnabled: Observable<Bool>
        var didUpdateProfile: Observable<Void>
        var showMessage: Observable<Message>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchProfile()
            })
            .disposed(by: bag)
        
        input
            .didChangeName
            .distinctUntilChanged()
            .bind(to: name)
            .disposed(by: bag)
        
        input
            .didChangeIntroduce
            .distinctUntilChanged()
            .bind(to: introduce)
            .disposed(by: bag)
        
        input
            .didChangeImage
            .bind(to: profileImage)
            .disposed(by: bag)
        
        input
            .saveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.updateProfile()
            })
            .disposed(by: bag)
        
        input
            .didChangeImage
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.imageChangeChecker = true
            })
            .disposed(by: bag)
            
        
        let saveBtnEnabled = name
            .compactMap { $0 }
            .map {
                !$0.isEmpty
            }
            .asObservable()
        
        return Output(
            didFetchName: name.asObservable(),
            didFetchIntroduce: introduce.asObservable(),
            didFetchImage: profileImage.map { $0?.data }.asObservable(),
            saveBtnEnabled: saveBtnEnabled,
            didUpdateProfile: didUpdateProfile.asObservable(),
            showMessage: showMessage.asObservable()
        )
    }
    
    func fetchProfile() {

        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Profile> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.readProfileUseCase.execute(token: token)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] profile in
                guard let self else { return }

                self.name.onNext(profile.nickName)
                self.introduce.onNext(profile.description)
                
                guard let key = profile.imageUrl else {
                    self.isInitialValueNil = true
                    return
                }
                self.isInitialValueNil = false
                self.fetchImage(key: key)
                    .subscribe(onSuccess: { data in
                        self.profileImage.onNext(ImageFile(filename: "originalProfile", data: data, type: "png"))
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
    }
    
    func updateProfile() {
        guard let name = try? name.value() else { return }
        
        var isImageRemoved: Bool = false
        var image: ImageFile?

        if let imageValue = try? profileImage.value() {
            image = (imageChangeChecker) ? imageValue : nil
        } else {
            isImageRemoved = !isInitialValueNil
        }

        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.updateProfileUseCase.execute(
                    token: token,
                    name: name,
                    introduce: try? self.introduce.value(),
                    isImageRemoved: isImageRemoved,
                    image: image
                )
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.didUpdateProfile.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        return useCases.fetchImageUseCase.execute(key: key)
    }
}
