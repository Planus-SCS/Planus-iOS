//
//  MyPageEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit
import RxSwift
import PhotosUI

class MyPageEditViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: MyPageEditViewModel?
    var didChangedImage = PublishSubject<ImageFile?>()
    var descEditing = false
    
    var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xB2CAFA)
        return view
    }()
    
    var bottomView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xF5F5FB)
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    var profileImageShadowView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowRadius = 2
        return view
    }()
    
    var profileImageView: UIImageView = {
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
        button.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
        return button
    }()
    
    var nameField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        textField.textAlignment = .left
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.cornerCurve = .continuous
        textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textField.backgroundColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: "이름을 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: 0xBFC7D7)])

        
        textField.addSidePadding(padding: 15)
        
        return textField
    }()
    
    lazy var introduceField: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.layer.cornerRadius = 10
        textView.layer.cornerCurve = .continuous
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self

        textView.text = "자기소개를 입력하세요."
        textView.textColor = UIColor(hex: 0xBFC7D7)
        return textView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveBtnAction))
        item.tintColor = UIColor(hex: 0x6495F4)
        return item
    }()
    
    convenience init(viewModel: MyPageEditViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
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
        navigationItem.setRightBarButton(saveButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.title = "프로필 수정"
    }
    
    @objc func backBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveBtnAction() {
        
    }
    
    @objc func editBtnTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //블로그 방문하기 버튼 - 스타일(default)
        actionSheet.addAction(UIAlertAction(title: "변경하기", style: .default, handler: {(ACTION:UIAlertAction) in
            self.presentPhotoPicker()
        }))
        
        //이웃 끊기 버튼 - 스타일(destructive)
        actionSheet.addAction(UIAlertAction(title: "제거", style: .destructive, handler: {(ACTION:UIAlertAction) in
            self.didChangedImage.onNext(nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = MyPageEditViewModel.Input(
            viewDidLoad: Observable.just(()),
            didChangeName: nameField.rx.text.asObservable(),
            didChangeIntroduce: introduceField.rx.text.asObservable().map { (self.descEditing) ? $0 : nil},
            didChangeImage: didChangedImage.asObservable(),
            saveBtnTapped: saveButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchName
            .distinctUntilChanged()
            .bind(to: nameField.rx.text)
            .disposed(by: bag)
        
        output
            .didFetchIntroduce
            .map {
                
                guard let str = $0 else { return nil }
                guard !str.isEmpty else { return nil }
                return str
            }
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text in
                self?.introduceField.text = text
                self?.introduceField.textColor = .black
                self?.descEditing = true
            })
            .disposed(by: bag)
        
        output
            .didFetchImage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                if let data = data {
                    vc.profileImageView.image = UIImage(data: data)
                } else {
                    vc.profileImageView.image = UIImage(named: "DefaultProfileMedium")
                }
            })
            .disposed(by: bag)
        
        output
            .saveBtnEnabled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, isEnabled in
                vc.saveButton.isEnabled = isEnabled
                vc.saveButton.tintColor = (isEnabled) ? UIColor(hex: 0x6495F4) : UIColor(hex: 0x6495F4).withAlphaComponent(0.5)
            })
            .disposed(by: bag)
        
        output
            .didUpdateProfile
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(contentView)
        contentView.addSubview(bottomView)
        contentView.addSubview(profileImageShadowView)
        profileImageShadowView.addSubview(profileImageView)
        contentView.addSubview(imageEditButton)
        bottomView.addSubview(nameField)
        bottomView.addSubview(introduceField)
    }
    
    func configureLayout() {
        contentView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
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

extension MyPageEditViewController: PHPickerViewControllerDelegate { //PHPicker 델리게이트
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (item, error) in
            guard let fileName = results.first?.itemProvider.suggestedName,
                  var image = item as? UIImage  else { return }
            
            image = UIImage.resizeImage(image: image, targetWidth: 500)
            if let data = image.jpegData(compressionQuality: 1) {
                self?.didChangedImage.onNext(ImageFile(filename: fileName, data: data, type: "jpeg"))
            }
        }
    }
}
                                    

extension MyPageEditViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "자기소개를 입력하세요."
            textView.textColor = UIColor(hex: 0xBFC7D7)
            descEditing = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !descEditing {
            textView.text = nil
            textView.textColor = .black
            descEditing = true
        }
    }
}

extension MyPageEditViewController: UIGestureRecognizerDelegate {}
