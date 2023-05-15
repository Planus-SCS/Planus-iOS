//
//  MyGroupInfoEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import UIKit
import RxSwift
import PhotosUI

class MyGroupInfoEditViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: MyGroupInfoEditViewModel?
    
    var titleImageChanged = PublishSubject<ImageFile?>()
    
    var scrollView = UIScrollView(frame: .zero)
    
    var contentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    
    var infoView: GroupEditInfoView = .init(frame: .zero)
    var tagView: GroupCreateTagView = .init(frame: .zero)
    var limitView: GroupCreateLimitView = .init(frame: .zero)
    var createButtonView: WideButtonView = .init(frame: .zero)
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    @objc func backBtnAction() {
        navigationController?.popViewController(animated: true)
    }
    
    convenience init(viewModel: MyGroupInfoEditViewModel) {
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
        
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        self.navigationItem.title = "그룹 생성"
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let tagFieldList: [UITextField] = [
            tagView.tagField1,
            tagView.tagField2,
            tagView.tagField3,
            tagView.tagField4,
            tagView.tagField5
        ]
        
        infoView.groupNameField.text = viewModel.title
        (try? viewModel.tagList.value())?.enumerated().forEach { index, tag in
            tagFieldList[index].text = tag
        }
        limitView.limitField.text = "\((try? viewModel.maxMember.value()) ?? 0)"
        
        let tagObservableList = tagFieldList
            .map {
                $0.rx.text.asObservable()
            }.map { str in
                return str.map {
                    return (($0?.isEmpty) ?? true) ? nil : $0
                }
            }
        
        let tagListChanged = Observable.combineLatest(tagObservableList)

        let input = MyGroupInfoEditViewModel.Input(
            titleImageChanged: titleImageChanged.asObservable(),
            tagListChanged: tagListChanged,
            maxMemberChanged: limitView.limitField.rx.text.asObservable(),
            saveBtnTapped: createButtonView.wideButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output
            .maxCountFilled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                vc.limitView.limitField.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)

        output
            .isUpdateButtonEnabled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, enabled in
                vc.createButtonView.wideButton.isEnabled = enabled
                vc.createButtonView.wideButton.alpha = enabled ? 1.0 : 0.4
            })
            .disposed(by: bag)
        
        output
            .tagCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.tagCountCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .tagCharCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.stringCountCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .tagSpecialCharValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.charValidateCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .didChangedTitleImage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                guard let data = data else {
                    vc.infoView.groupImageView.image = UIImage(named: "GroupCreateDefaultImage")
                    return
                }
                vc.infoView.groupImageView.image = UIImage(data: data)
            })
            .disposed(by: bag)
        
        output
            .infoUpdateCompleted
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(infoView)
        contentStackView.addArrangedSubview(tagView)
        contentStackView.addArrangedSubview(limitView)
        contentStackView.addArrangedSubview(createButtonView)
        
        infoView.groupImageButton.addTarget(self, action: #selector(imageBtnTapped), for: .touchUpInside)
    }
    
    @objc func imageBtnTapped(_ sender: UIButton) {
        presentPhotoPicker()
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
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

extension MyGroupInfoEditViewController: PHPickerViewControllerDelegate { //PHPicker 델리게이트
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            guard let fileName = results.first?.itemProvider.suggestedName else { return }
            if let data = (image as? UIImage)?.pngData() {
                self?.titleImageChanged.onNext(ImageFile(filename: fileName, data: data, type: "png"))
            }
        }
    }
}
