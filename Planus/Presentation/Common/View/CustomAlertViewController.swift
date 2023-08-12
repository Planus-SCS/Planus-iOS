//
//  CustomAlertViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/29.
//

import UIKit

final class CustomAlertViewController: UIViewController {
    private var titleText: String
    private var messageText: String?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF5F5FB)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 14
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleText
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.numberOfLines = 0
        label.textColor = .black.withAlphaComponent(0.9)
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = messageText
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .black.withAlphaComponent(0.9)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - init
    init(titleText: String, messageText: String?) {
        self.titleText = titleText
        self.messageText = messageText
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.alpha = 0.0
        view.backgroundColor = .black.withAlphaComponent(0)
        containerView.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.alpha = 1.0
            self?.view.backgroundColor = .black.withAlphaComponent(0.4)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIView.animate(
            withDuration: 0.15,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { [weak self] in
                self?.containerView.alpha = 0.0
                self?.view.backgroundColor = .black.withAlphaComponent(0)
            },
            completion: { [weak self] _ in
                self?.containerView.isHidden = true
            }
        )
    }
    
    // MARK: - setup
    private func configure() {
        view.addSubview(containerView)
        containerView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(messageLabel)
        containerStackView.addArrangedSubview(buttonStackView)
        containerStackView.setCustomSpacing(12, after: titleLabel)
        containerStackView.setCustomSpacing(18, after: messageLabel)
    }

    private func configureLayout() {
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.top.greaterThanOrEqualToSuperview().inset(32)
            $0.bottom.lessThanOrEqualToSuperview().inset(32)
        }

        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.bottom.leading.trailing.equalTo(containerView).inset(24)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(containerStackView.snp.width)
        }
    }
    
    // MARK: - methods
    public func addActionToButton(title: String? = nil,
                                  titleColor: UIColor = .white,
                                  backgroundColor: UIColor,
                                  completion: (() -> Void)? = nil) {
        let button = SpringableButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 12)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backgroundColor
        
        button.layer.cornerRadius = 6.0
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        
        let action = UIAction { [weak self] _ in
            completion?()
        }
        button.addAction(action, for: .touchUpInside)

        buttonStackView.addArrangedSubview(button)
    }
}

struct CustomAlertAttr {
    var title: String
    var actionHandler: () -> Void
    var type: AlertType
}

enum AlertType {
    case normal
    case warning
    
    var textColor: UIColor {
        switch self {
        case .normal:
            return UIColor(hex: 0x3D458A)
        case .warning:
            return .systemPink
        }
    }
}

extension UIViewController {
    
    func showPopUp(
        title: String,
        message: String?,
        alertAttrs: [CustomAlertAttr]
    ) {
        let customAlert = CustomAlertViewController(titleText: title,
                                      messageText: message)
        alertAttrs.forEach { attr in
            
            customAlert.addActionToButton(title: attr.title,
                                          titleColor: attr.type.textColor,
                                          backgroundColor: UIColor(hex: 0xDFDFE3)) {
                customAlert.dismiss(animated: false, completion: attr.actionHandler)
            }
        }
        present(customAlert, animated: false, completion: nil)
    }
    
    func showErrorPopUp(title: String, message: String?, alertAttr: CustomAlertAttr) -> (() -> Void) {
        let customAlert = CustomAlertViewController(titleText: title,
                                      messageText: message)
            
            customAlert.addActionToButton(title: alertAttr.title,
                                          titleColor: alertAttr.type.textColor,
                                          backgroundColor: UIColor(hex: 0xDFDFE3)) {
                alertAttr.actionHandler()
            }
        
        present(customAlert, animated: false, completion: nil)
        return { customAlert.dismiss(animated: false) }
    }
}
