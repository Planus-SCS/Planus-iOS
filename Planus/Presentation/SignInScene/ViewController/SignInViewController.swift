//
//  SignInViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit
import SnapKit

class SignInViewController: UIViewController {
        
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
    
    var kakaoSignButton: UIButton = {
        let image = UIImage(named: "kakaoBtn")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    var googleSigninButton: UIButton = {
        let image = UIImage(named: "googleBtn")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    var appleSigninButton: UIButton = {
        let image = UIImage(named: "appleBtn")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
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

}
