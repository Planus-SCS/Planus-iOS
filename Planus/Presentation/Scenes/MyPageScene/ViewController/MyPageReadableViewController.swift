//
//  MyPageReadableViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit

class MyPageReadableViewController: UIViewController {
    
    var viewModel: MyPageReadableViewModel?
    
    var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isEditable = false
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        textView.backgroundColor = UIColor(hex: 0xF5F5FB)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10

        let attributedString = NSMutableAttributedString(string: textView.text)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))

        textView.attributedText = attributedString
        return textView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: MyPageReadableViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

private extension MyPageReadableViewController {
    func bind() {
        guard let viewModel else { return }
        let input = MyPageReadableViewModel.Input(
            backBtnTapped: backButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        navigationItem.title = output.navigationTitle
        textView.text = output.text
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(textView)
    }
    
    func configureLayout() {
        textView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

extension MyPageReadableViewController: UIGestureRecognizerDelegate {}
