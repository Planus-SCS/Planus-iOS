//
//  TodoDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift
import RxCocoa

final class TodoDetailViewController: UIViewController {
    var keyboardBag: DisposeBag?
    var bag = DisposeBag()
    
    var pageDismissCompletionHandler: (() -> Void)?
    var isFirstAppear = true
    
    // MARK: send ControlProperties to ViewModel
    var didSelectCategoryAt = PublishSubject<Int?>()
    var didRequestEditCategoryAt = PublishSubject<Int>()
    var didSelectedDateRange = PublishSubject<DateRange>()
    var didSelectedGroupAt = PublishSubject<Int?>()
    var didChangednewCategoryColor = PublishSubject<CategoryColor?>()
    var didDeleteCategoryId = PublishSubject<Int>()
    var didChangedTimeValue = PublishSubject<String?>()
    
    var isMemoActive = BehaviorSubject<Bool?>(value: nil)
    lazy var memoObservable = Observable.combineLatest(
        isMemoActive.compactMap { $0 }.asObservable(),
        todoDetailView.memoView.memoTextView.rx.text.asObservable()
    ).map { args -> String? in
        let (isActive, text) = args
        guard isActive else { return nil }
        return text ?? String()
    }
    
    var pageType: TodoDetailViewControllerPageType = .todoDetail

    var viewModel: TodoDetailViewModelable?
    
    // MARK: Child ViewController
    var dayPickerViewController = DayPickerViewController(nibName: nil, bundle: nil)
    
    // MARK: Child View
    var todoDetailView = TodoDetailView(frame: .zero)
    var categoryView = CategorySelectView(frame: .zero)
    var categoryCreateView = CategoryCreateView(frame: .zero)
    
    // MARK: Background
    let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0)
        return view
    }()
    
    convenience init(viewModel: TodoDetailViewModelable) {
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
    
    func configureAddTodoView() {
        dayPickerViewController.delegate = self
        
        todoDetailView.icnView.delegate = self
        todoDetailView.groupView.groupPickerView.dataSource = self
        todoDetailView.groupView.groupPickerView.delegate = self
        
        todoDetailView.clockView.timePicker.addTarget(self, action: #selector(didChangeTime), for: .valueChanged)
        
        todoDetailView.addSubview(dayPickerViewController.view)
    }
    
    func configureSelectCategoryView() {
        categoryView.tableView.dataSource = self
        categoryView.tableView.delegate = self
    }
    
    func configureCreateCategoryView() {
        categoryCreateView.collectionView.dataSource = self
        categoryCreateView.collectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstAppear {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                 self.todoDetailView.snp.remakeConstraints {
                     $0.bottom.leading.trailing.equalToSuperview()
                     $0.height.lessThanOrEqualTo(700)
                 }
                 self.dimmedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
                 self.view.layoutIfNeeded()
             }, completion: nil)
            isFirstAppear = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pageDismissCompletionHandler?()
    }

    // 3
    @objc private func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    
    func bind() {
        guard let viewModel else { return }

        let input = TodoDetailViewModelableInput( //스킵을 해도 이러는가??
            titleTextChanged: todoDetailView.titleView.todoTitleField.rx.text.skip(1).asObservable(),
            categorySelectedAt: didSelectCategoryAt.asObservable(),
            dayRange: didSelectedDateRange.distinctUntilChanged().asObservable(),
            timeFieldChanged: didChangedTimeValue.asObservable(),
            groupSelectedAt: didSelectedGroupAt.distinctUntilChanged().asObservable(),
            memoTextChanged: memoObservable,
            creatingCategoryNameTextChanged: categoryCreateView.nameField.rx.text.asObservable(),
            creatingCategoryColorChanged: didChangednewCategoryColor.asObservable(),
            didRemoveCategory: didDeleteCategoryId.asObservable(),
            categoryEditRequested: didRequestEditCategoryAt.asObservable(),
            categorySelectBtnTapped: todoDetailView.titleView.categoryButton.rx.tap.asObservable(),
            todoSaveBtnTapped: todoDetailView.saveButton.rx.tap.asObservable(),
            todoRemoveBtnTapped: todoDetailView.removeButton.rx.tap.asObservable(),
            newCategoryAddBtnTapped: categoryView.addNewItemButton.rx.tap.asObservable(),
            newCategorySaveBtnTapped: categoryCreateView.saveButton.rx.tap.asObservable(),
            categorySelectPageBackBtnTapped: categoryView.backButton.rx.tap.asObservable(),
            categoryCreatePageBackBtnTapped: categoryCreateView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .titleValueChanged
            .bind(to: todoDetailView.titleView.todoTitleField.rx.text)
            .disposed(by: bag)
        
        output
            .memoValueChanged
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, text in
                vc.todoDetailView.memoView.memoTextView.text = text
                
                let memoAttrIndex = TodoDetailAttribute.memo.rawValue
                vc.todoDetailView.icnView.buttonList[memoAttrIndex].tintColor = (text == nil) ? .gray : .black
            })
            .disposed(by: bag)
        
        output
            .dayRangeChanged
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] range in
                self?.dayPickerViewController.setDate(startDate: range.start, endDate: range.end)
            })
            .disposed(by: bag)
        
        output
            .timeValueChanged
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, time in
                let clockAttrIndex = TodoDetailAttribute.clock.rawValue
                vc.todoDetailView.icnView.buttonList[clockAttrIndex].tintColor = (time == nil) ? .gray : .black
                guard let time else { return }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "HH:mm"
                
                let date = dateFormatter.date(from: time)!
                
                vc.todoDetailView.clockView.timePicker.date = date
            })
            .disposed(by: bag)
        
        output
            .categoryChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { vc, category in
                if let category {
                    vc.todoDetailView.titleView.categoryButton.categoryLabel.text = category.title
                    vc.todoDetailView.titleView.categoryButton.categoryLabel.textColor = UIColor(hex: 0x000000)
                    vc.todoDetailView.titleView.categoryButton.categoryColorView.backgroundColor = category.color.todoForCalendarColor
                } else {
                    vc.todoDetailView.titleView.categoryButton.categoryLabel.text = "카테고리 선택"
                    vc.todoDetailView.titleView.categoryButton.categoryLabel.textColor = UIColor(hex: 0xBFC7D7)
                    vc.todoDetailView.titleView.categoryButton.categoryColorView.backgroundColor = .gray
                }
                vc.moveFromSelectToAdd()
            })
            .disposed(by: bag)
        
        output
            .groupChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { vc, groupName in
                let groupAttrIndex = TodoDetailAttribute.group.rawValue
                vc.todoDetailView.icnView.buttonList[groupAttrIndex].tintColor = (groupName == nil) ? .gray : .black
                
                if let groupName {
                    let index = viewModel.groups.firstIndex(of: groupName) ?? 0
                    vc.todoDetailView.groupView.groupPickerView.selectRow(index, inComponent: 0, animated: false)
                }
            })
            .disposed(by: bag)
        
        output
            .newCategorySaveBtnEnabled
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, isEnabled in
                vc.categoryCreateView.saveButton.isEnabled = isEnabled
                vc.categoryCreateView.saveButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: bag)
        
        output
            .newCategorySaved
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe { vc, _ in
                vc.categoryView.tableView.reloadData()
            }
            .disposed(by: bag)
        
        output
            .moveFromAddToSelect
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.moveFromAddToSelect()
            })
            .disposed(by: bag)
        
        output
            .moveFromSelectToCreate
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.moveFromSelectToCreate()
            })
            .disposed(by: bag)
        
        output
            .moveFromCreateToSelect
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.moveFromCreateToSelect()
                vc.categoryCreateView.nameField.text = nil
                guard let index = vc.categoryCreateView.collectionView.indexPathsForSelectedItems?.first else { return }
                vc.categoryCreateView.collectionView.deselectItem(at: index, animated: false)
            })
            .disposed(by: bag)
        
        output
            .moveFromSelectToAdd
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.moveFromSelectToAdd()
            })
            .disposed(by: bag)
        
        output
            .removeKeyboard
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.view.endEditing(true)
            })
            .disposed(by: bag)
        
        output
            .needDismiss
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: bag)
        
        output
            .showSaveConstMessagePopUp
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.showPopUp(
                    title: "일정, 카테고리는 필수에요",
                    message: "멘트가\n떠오르지 않을 때도 있죠 😌",
                    alertAttrs: [CustomAlertAttr(title: "확인", actionHandler: {}, type: .normal)]
                )
            })
            .disposed(by: bag)
                        
        todoDetailView.setMode(mode: viewModel.mode)

        viewModel.initFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func didChangeTime(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateStr = dateFormatter.string(from: sender.date)
        
        didChangedTimeValue.onNext(dateStr)
    }
}

// MARK: Generate UI
extension TodoDetailViewController {
    func configureView() {
        self.view.addSubview(dimmedView)
        self.view.addSubview(todoDetailView)
        
        [todoDetailView.upperView,
         todoDetailView.icnView,
         dayPickerViewController.view,
         todoDetailView.curtainView].forEach {
            $0?.backgroundColor = UIColor(hex: 0xF5F5FB)
        }
        
        self.view.addSubview(categoryView)
        self.view.addSubview(categoryCreateView)
        
        configureAddTodoView()
        configureSelectCategoryView()
        configureCreateCategoryView()
        
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(_:)))
        dimmedView.addGestureRecognizer(dimmedTap)
        dimmedView.isUserInteractionEnabled = true
    }
    
    func configureLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        todoDetailView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.snp.bottom)
            $0.height.lessThanOrEqualTo(700)
        }
        
        categoryView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalTo(self.view.snp.trailing)
            $0.height.equalTo(400)
            $0.bottom.equalToSuperview()
        }
        
        categoryCreateView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalTo(self.view.snp.trailing)
            $0.height.lessThanOrEqualTo(800)
            $0.bottom.equalToSuperview()
        }
        
        dayPickerViewController.view.snp.makeConstraints {
            $0.top.equalTo(todoDetailView.icnView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview()
        }
        
        self.view.layoutIfNeeded()
    }
}

extension TodoDetailViewController: TodoDetailIcnViewDelegate {
    func deactivate(attr: TodoDetailAttribute) {
        switch attr {
        case .title:
            todoDetailView.titleView.todoTitleField.text = nil
        case .calendar:
            dayPickerViewController.setDate(startDate: nil, endDate: nil)
        case .clock:
            didChangedTimeValue.onNext(nil)
        case .group:
            didSelectedGroupAt.onNext(nil)
        case .memo:
            isMemoActive.onNext(false)
            todoDetailView.memoView.memoTextView.text = nil
        }
    }
    
    func move(from: TodoDetailAttribute, to: TodoDetailAttribute) {
        if from != to {
            if to != .title {
                todoDetailView.titleView.set1line()
            } else {
                todoDetailView.titleView.set2lines()
            }
            
            if from != .title {
                self.todoDetailView.attributeViewGroup[from.rawValue].bottomConstraint.isActive = false
            }
            if to != .title {
                let newAnchor = self.todoDetailView.attributeViewGroup[to.rawValue].bottomAnchor.constraint(equalTo: self.todoDetailView.contentView.bottomAnchor)
                self.todoDetailView.attributeViewGroup[to.rawValue].bottomConstraint = newAnchor
                newAnchor.isActive = true
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                if from != .title {
                    self.todoDetailView.attributeViewGroup[from.rawValue].alpha = 0
                }
                if to != .title {
                    self.todoDetailView.attributeViewGroup[to.rawValue].alpha = 1
                }
            })
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.todoDetailView.upperView.layoutIfNeeded()
            })
        }
        
        switch to {
        case .title:
            todoDetailView.titleView.todoTitleField.becomeFirstResponder()
        case .calendar:
            self.view.endEditing(true)
        case .clock:
            todoDetailView.titleView.todoTitleField.becomeFirstResponder()
            didChangeTime(todoDetailView.clockView.timePicker)
        case .group:
            todoDetailView.titleView.todoTitleField.becomeFirstResponder()
            let index = todoDetailView.groupView.groupPickerView.selectedRow(inComponent: 0)
            didSelectedGroupAt.onNext(index)
        case .memo:
            isMemoActive.onNext(true)
            todoDetailView.memoView.memoTextView.becomeFirstResponder()
        }
    }
}
