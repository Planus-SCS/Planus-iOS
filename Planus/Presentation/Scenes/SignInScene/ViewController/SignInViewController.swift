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

final class SignInView: UIView {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: Configure UI
private extension SignInView {
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        
        self.addSubview(logoImageView)
        self.addSubview(greetingLabel)
        self.addSubview(kakaoSignButton)
        self.addSubview(googleSigninButton)
        self.addSubview(appleSigninButton)
    }
    
    func configureLayout() {
        greetingLabel.snp.makeConstraints {
            $0.center.equalTo(self.safeAreaLayoutGuide.snp.center)
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
}

final class SignInViewController: UIViewController {
    let bag = DisposeBag()
    let didReceiveAppleIdentityToken = PublishSubject<(String, PersonNameComponents?)>()
    
    var viewModel: SignInViewModel?
    var signInView: SignInView?

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
    
    override func loadView() {
        super.loadView()
        
        let view = SignInView(frame: self.view.frame)
        self.view = view
        self.signInView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }
}

//MARK: View Generator
private extension SignInViewController {
    func bind() {
        guard let viewModel,
              let signInView else { return }
        
        let input = SignInViewModel.Input(
            kakaoSignInTapped: signInView.kakaoSignButton.rx.tap.asObservable(),
            googleSignInTapped: signInView.googleSigninButton.rx.tap.asObservable(),
            appleSignInTapped: signInView.appleSigninButton.rx.tap.asObservable(),
            didReceiveAppleIdentityToken: didReceiveAppleIdentityToken.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .showAppleSignInPage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, request in
                vc.showASAuthController(request: request)
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: bag)
    }
}

//MARK: Apple SignIn
extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func showASAuthController(request: ASAuthorizationAppleIDRequest) {
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) {
            var fullName: PersonNameComponents? = nil
            
            if let userFullName = appleIDCredential.fullName,
               let givenName = userFullName.givenName,
               let familyName = userFullName.familyName {
                fullName = PersonNameComponents(givenName: givenName, familyName: familyName)
            }

            didReceiveAppleIdentityToken.onNext((identityToken, fullName))
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
