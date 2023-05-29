//
//  SignInViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AuthenticationServices

class SignInViewController: UIViewController {
    var bag = DisposeBag()
    
    var didReceiveAppleIdentityToken = PublishSubject<String>()
    
    var viewModel: SignInViewModel?
    
    var logoImageView: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0)
        )
        imageView.image = image
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var greetingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = """
플래너스에 오신것을 환영합니다!
아래 버튼을 눌러 시작해 보세요.
"""
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.391, green: 0.584, blue: 0.958, alpha: 1)
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        return label
    }()
    
    var kakaoSignButton: SpringableButton = {
        let image = UIImage(named: "kakaoBtn")
        let button = SpringableButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    var googleSigninButton: SpringableButton = {
        let image = UIImage(named: "googleBtn")
        let button = SpringableButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    var appleSigninButton: SpringableButton = {
        let image = UIImage(named: "appleBtn")
        let button = SpringableButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    convenience init(viewModel: SignInViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()

        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = SignInViewModel.Input(
            kakaoSignInTapped: kakaoSignButton.rx.tap.asObservable(),
            googleSignInTapped: googleSigninButton.rx.tap.asObservable(),
            appleSignInTapped: appleSigninButton.rx.tap.asObservable(),
            didReceiveAppleIdentityToken: didReceiveAppleIdentityToken.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .showAppleSignInPage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.appleSignInBtnTapped()
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        
        self.view.addSubview(logoImageView)
        self.view.addSubview(greetingLabel)
        self.view.addSubview(kakaoSignButton)
        self.view.addSubview(googleSigninButton)
        self.view.addSubview(appleSigninButton)
    }
    
    func configureLayout() {
        greetingLabel.snp.makeConstraints {
            $0.center.equalTo(self.view.safeAreaLayoutGuide.snp.center)
        }
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(greetingLabel.snp.top)
        }
        
        kakaoSignButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(greetingLabel.snp.bottom).offset(39)
        }
        
        googleSigninButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(kakaoSignButton.snp.bottom).offset(16)
        }
        
        appleSigninButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(googleSigninButton.snp.bottom).offset(16)
        }
    }

    func appleSignInBtnTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

}

extension SignInViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user //이걸 키체인 같은데에 저장해서 앱 다시켤때마다 증명된지 확인
            appleIDCredential.identityToken //애를 백엔드로 보내서 jwt를 발급받는다고함
            appleIDCredential
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}


extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
