//
//  CategoryDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift
import RxCocoa

final class CategoryDetailViewController: UIViewController {
    private let bag = DisposeBag()
    private var currentKeyboardHeight: CGFloat = 0

    // MARK: UI Event
    private let categoryColorSelected = PublishRelay<CategoryColor?>()
    private let needDismiss = PublishRelay<Void>()
        
    private var viewModel: (any CategoryDetailViewModelable)?
    
    // MARK: Child View
    private let categoryCreateView = CategoryCreateView(frame: .zero)
    
    // MARK: Background
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        return view
    }()
    
    convenience init(viewModel: any CategoryDetailViewModelable) {
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
        configureKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryCreateView.nameField.becomeFirstResponder()
    }
}

// MARK: - bind viewModel
extension CategoryDetailViewController {
    func bind() {
        guard let viewModel else { return }

        let input = (any CategoryDetailViewModelable).Input(
            categoryColorSelected: categoryColorSelected.asObservable(),
            categoryTitleChanged: categoryCreateView.nameField.rx.text.skip(1).asObservable(),
            saveBtnTapped: categoryCreateView.saveButton.rx.tap.asObservable(),
            backBtnTapped: categoryCreateView.backButton.rx.tap.asObservable(),
            needDismiss: needDismiss.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state), fromBotton: vc.currentKeyboardHeight + 30)
            })
            .disposed(by: bag)
        
        output
            .saveBtnEnabled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, isEnabled in
                vc.categoryCreateView.saveButton.isEnabled = isEnabled
                vc.categoryCreateView.saveButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: bag)

        categoryCreateView.nameField.text = output.categoryTitleValue
        
        guard let categoryIndex = output.categoryColorIndexValue else { return }
        categoryCreateView.collectionView.selectItem(
            at: IndexPath(item: categoryIndex, section: 0),
            animated: false,
            scrollPosition: .top
        )
    }
}

// MARK: Configure VC
private extension CategoryDetailViewController {
    func configureCreateCategoryView() {
        categoryCreateView.collectionView.dataSource = self
        categoryCreateView.collectionView.delegate = self
    }
    
    func configureDimmedView() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(_:)))
        dimmedView.addGestureRecognizer(dimmedTap)
        dimmedView.isUserInteractionEnabled = true
    }
    
    func configureKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func configureView() {
        self.view.addSubview(dimmedView)
        self.view.addSubview(categoryCreateView)

        configureCreateCategoryView()
    }
    
    func configureLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        categoryCreateView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.lessThanOrEqualTo(800)
        }
    }
}

// MARK: - DimmedView Tap Animation
private extension CategoryDetailViewController {
    @objc
    func dimmedViewTapped(_ sender: UITapGestureRecognizer) {
        animateDismiss()
    }
    
    func animateDismiss() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.dimmedView.alpha = 0.0
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.height.lessThanOrEqualTo(800)
                $0.top.equalTo(self.dimmedView.snp.bottom)
            }
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.needDismiss.accept(())
        })
    }
}


// MARK: - collectionView
extension CategoryDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.categoryColorList.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCreateCell.reuseIdentifier, for: indexPath) as? CategoryCreateCell,
              let item = viewModel?.categoryColorList[indexPath.item] else { return UICollectionViewCell() }
        cell.fill(color: item.todoLeadingColor)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel?.categoryColorList[indexPath.item] else { return }
        categoryColorSelected.accept(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        categoryColorSelected.accept(nil)
    }
}

// MARK: - Keyboard Actions
private extension CategoryDetailViewController {
    @objc
    func keyboardWillShow(_ notification:NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            currentKeyboardHeight = keyboardHeight
            categoryCreateView.descLabel.snp.remakeConstraints {
                $0.top.equalTo(categoryCreateView.collectionView.snp.bottom)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(keyboardHeight+20)
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}
