//
//  MyPageEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class MyPageEditView: UIView {
    let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .planusBlueGroundColor
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .planusBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    let profileImageShadowView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowRadius = 2
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.layer.cornerCurve = .continuous
        imageView.image = UIImage(named: "DefaultProfileMedium")

        return imageView
    }()
    
    lazy var imageEditButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "cameraBtn"), for: .normal)
        return button
    }()
    
    let nameField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .planusBlack
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        textField.textAlignment = .left
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.cornerCurve = .continuous
        textField.layer.borderColor = UIColor.planusDeepNavy.cgColor
        textField.backgroundColor = .planusWhite
        textField.attributedPlaceholder = NSAttributedString(string: "이름을 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.planusLightGray])

        
        textField.addSidePadding(padding: 10)
        
        return textField
    }()
    
    lazy var introduceField: PlaceholderTextView = {
        let textView = PlaceholderTextView(frame: .zero)
        textView.layer.cornerRadius = 10
        textView.layer.cornerCurve = .continuous
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.planusDeepNavy.cgColor
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.placeholder = "자기소개를 입력하세요."
        textView.placeholderColor = .planusLightGray
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        textView.textColor = .planusBlack
        return textView
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

// MARK: configure UI
private extension MyPageEditView {
    func configureView() {
        self.backgroundColor = .planusBackgroundColor
        self.addSubview(contentView)
        contentView.addSubview(bottomView)
        contentView.addSubview(profileImageShadowView)
        profileImageShadowView.addSubview(profileImageView)
        contentView.addSubview(imageEditButton)
        bottomView.addSubview(nameField)
        bottomView.addSubview(introduceField)
    }
    
    func configureLayout() {
        contentView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(44)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        profileImageShadowView.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(44)
        }
        
        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageEditButton.snp.makeConstraints {
            $0.trailing.equalTo(profileImageShadowView).offset(17)
            $0.bottom.equalTo(profileImageShadowView)
        }
        
        nameField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(56)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        introduceField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(82)
            $0.top.equalTo(nameField.snp.bottom).offset(16)
        }
    }
}

final class MyPageEditViewController: UIViewController {
    
    private let bag = DisposeBag()
    private var viewModel: MyPageEditViewModel?
    private var myPageEditView: MyPageEditView?
    
    private let didChangedImage = PublishRelay<ImageFile?>()
    private var descEditing = false
    
    private lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .planusBlack
        return item
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "saveBarBtn"), style: .plain, target: nil, action: nil)
        item.tintColor = .planusTintBlue
        return item
    }()
    
    convenience init(viewModel: MyPageEditViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = MyPageEditView(frame: self.view.frame)
        self.view = view
        self.myPageEditView = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(saveButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.title = "프로필 수정"
    }
}

// MARK: Actions
private extension MyPageEditViewController {
    func editBtnTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "변경하기", style: .default, handler: {(ACTION:UIAlertAction) in
            self.presentPhotoPicker()
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "제거", style: .destructive, handler: {(ACTION:UIAlertAction) in
            self.didChangedImage.accept(nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func presentPhotoPicker() {
        var phPickerConfiguration = PHPickerConfiguration()
        phPickerConfiguration.selectionLimit = 1
        phPickerConfiguration.filter = .images
        phPickerConfiguration.preferredAssetRepresentationMode = .current

        let phPicker = PHPickerViewController(configuration: phPickerConfiguration)
        phPicker.delegate = self
        self.present(phPicker, animated: true)
    }
}

// MARK: Configure
private extension MyPageEditViewController {
    func bind() {
        guard let viewModel,
              let myPageEditView else { return }
        
        myPageEditView
            .imageEditButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.editBtnTapped()
            })
            .disposed(by: bag)
        
        let input = MyPageEditViewModel.Input(
            viewDidLoad: Observable.just(()),
            didChangeName: myPageEditView.nameField.rx.text.skip(1).asObservable(),
            didChangeIntroduce: myPageEditView.introduceField.rx.text.skip(1).asObservable(),
            didChangeImage: didChangedImage.asObservable(),
            saveBtnTapped: saveButton.rx.tap.asObservable(),
            backBtnTapped: backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchName
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(myPageEditView.nameField.rx.text)
            .disposed(by: bag)
        
        output
            .didFetchIntroduce
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(myPageEditView.introduceField.rx.text)
            .disposed(by: bag)
        
        output
            .didFetchImage
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { data in
                if let data = data {
                    myPageEditView.profileImageView.image = UIImage(data: data)
                } else {
                    myPageEditView.profileImageView.image = UIImage(named: "DefaultProfileMedium")
                }
            })
            .disposed(by: bag)
        
        output
            .saveBtnEnabled
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
                self?.saveButton.tintColor = (isEnabled) ? .planusTintBlue : .planusTintBlue.withAlphaComponent(0.5)
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.view.endEditing(true)
                vc.showToast(message: message)
            })
            .disposed(by: bag)
    }
}

extension MyPageEditViewController: PHPickerViewControllerDelegate { //PHPicker 델리게이트
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (item, error) in
            guard let fileName = results.first?.itemProvider.suggestedName,
                  var image = item as? UIImage  else { return }
            
            image = UIImage.resizeImage(image: image, targetWidth: 500)
            if let data = image.jpegData(compressionQuality: 1) {
                self?.didChangedImage.accept(ImageFile(filename: fileName, data: data, type: "jpeg"))
            }
        }
    }
}

extension MyPageEditViewController: UIGestureRecognizerDelegate {}
