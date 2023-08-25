//
//  TodoDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift
import RxCocoa

class TodoDetailViewController: UIViewController {
    var keyboardBag: DisposeBag?
    var bag = DisposeBag()
    var completionHandler: (() -> Void)?
    var firstAppear = true
    
    var didSelectCategoryAt = PublishSubject<Int?>()
    var didRequestEditCategoryAt = PublishSubject<Int>() // 생성도 이걸로하자!
    var didSelectedDateRange = PublishSubject<DateRange>()
    var didSelectedGroupAt = PublishSubject<Int?>()
    var didChangednewCategoryColor = PublishSubject<CategoryColor?>()
    var didDeleteCategoryId = PublishSubject<Int>()
    var didChangedTimeValue = PublishSubject<String?>()
    
    var isMemoActive = BehaviorSubject<Bool?>(value: nil)
    
    var pageType: AddTodoViewControllerPageType = .addTodo

    var viewModel: TodoDetailViewModelable?
    
    // MARK: Child ViewController
    var dayPickerViewController = DayPickerViewController(nibName: nil, bundle: nil)
    
    // MARK: Child View
    var addTodoView = TodoDetailView2(frame: .zero)
    var categoryView = CategorySelectView(frame: .zero)
    var categoryCreateView = CategoryCreateView(frame: .zero)
    
    // MARK: Background
    private let dimmedView: UIView = {
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
        
        addTodoView.icnView.delegate = self
        addTodoView.groupView.groupPickerView.dataSource = self
        addTodoView.groupView.groupPickerView.delegate = self
        
        addTodoView.addSubview(dayPickerViewController.view)
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
        
        if firstAppear {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                 self.addTodoView.snp.remakeConstraints {
                     $0.bottom.leading.trailing.equalToSuperview()
                     $0.height.lessThanOrEqualTo(700)
                 }
                 self.dimmedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
                 self.view.layoutIfNeeded()
             }, completion: nil)
            firstAppear = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        completionHandler?()
    }
    
    private func hideBottomSheetAndGoBack() {

        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimmedView.alpha = 0.0
            switch self.pageType {
            case .addTodo:
                self.addTodoView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.top.equalTo(self.dimmedView.snp.bottom)
                    $0.height.lessThanOrEqualTo(700)
                }
            case .selectCategory:
                self.categoryView.snp.remakeConstraints {
                    $0.width.equalToSuperview()
                    $0.leading.equalToSuperview()
                    $0.height.equalTo(400)
                    $0.top.equalTo(self.dimmedView.snp.bottom)
                }
            case .createCategory:
                self.categoryCreateView.snp.remakeConstraints {
                    $0.width.equalToSuperview()
                    $0.leading.equalToSuperview()
                    $0.height.lessThanOrEqualTo(800)
                    $0.top.equalTo(self.dimmedView.snp.bottom)
                }
            }

            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }

    // 3
    @objc private func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    func configureView() {
        self.view.addSubview(dimmedView)
        self.view.addSubview(addTodoView)
        
        [addTodoView.upperView, addTodoView.icnView, dayPickerViewController.view, addTodoView.curtainView].forEach {
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
        
        addTodoView.snp.makeConstraints {
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
            $0.top.equalTo(addTodoView.icnView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview()
        }
        
        self.view.layoutIfNeeded()
    }
    
    func bind() {
        guard let viewModel else { return }
//
//        addTodoView.memoView.memoTextView.rx.text.subscribe(onNext: { text in
//            print("in rx test, ", text)
//        })
//        .disposed(by: bag) //일단 알게된점: 애는 nil인적이 단한번도 없다.
//
        let memoObservable = Observable.combineLatest(
            isMemoActive.compactMap { $0 }.asObservable(), //처음 아이콘 누르면 애가 액티브, 화면을 firstResponder가 된 그시기...?
            addTodoView.memoView.memoTextView.rx.text.asObservable() //responder가 된다고 초기값이 한번 더뜨는건 아님. 걍 스킵없이 넣자
        ).map { args -> String? in
            let (isActive, text) = args
            guard isActive else { return nil }
            return text ?? ""
        } //일단은 이방식이 최선일듯 하다... 메모만 써? 아님 다?

        let input = TodoDetailViewModelableInput( //스킵을 해도 이러는가??
            titleTextChanged: addTodoView.titleView.todoTitleField.rx.text.skip(1).asObservable(), //첫번째 값 + becomeFirstResponder 시 값
            categorySelectedAt: didSelectCategoryAt.asObservable(),
            dayRange: didSelectedDateRange.distinctUntilChanged().asObservable(),
            timeFieldChanged: didChangedTimeValue.asObservable(),
            groupSelectedAt: didSelectedGroupAt.distinctUntilChanged().asObservable(),
            memoTextChanged: memoObservable,
            creatingCategoryNameTextChanged: categoryCreateView.nameField.rx.text.asObservable(),
            creatingCategoryColorChanged: didChangednewCategoryColor.asObservable(),
            didRemoveCategory: didDeleteCategoryId.asObservable(),
            categoryEditRequested: didRequestEditCategoryAt.asObservable(),
            categorySelectBtnTapped: addTodoView.titleView.categoryButton.rx.tap.asObservable(),
            todoSaveBtnTapped: addTodoView.saveButton.rx.tap.asObservable(),
            todoRemoveBtnTapped: addTodoView.removeButton.rx.tap.asObservable(),
            newCategoryAddBtnTapped: categoryView.addNewItemButton.rx.tap.asObservable(),
            newCategorySaveBtnTapped: categoryCreateView.saveButton.rx.tap.asObservable(),
            categorySelectPageBackBtnTapped: categoryView.backButton.rx.tap.asObservable(),
            categoryCreatePageBackBtnTapped: categoryCreateView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        addTodoView.icnView.buttonList[0].tintColor = .black
        addTodoView.icnView.buttonList[1].tintColor = .black
        addTodoView.clockView.timePicker.addTarget(self, action: #selector(didChangeTime), for: .valueChanged)
        
        output
            .titleValueChanged
            .bind(to: addTodoView.titleView.todoTitleField.rx.text)
            .disposed(by: bag)
        
        output
            .memoValueChanged
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, text in
                print("vc memo: ", text)
                vc.addTodoView.memoView.memoTextView.text = text
                
                let memoAttrIndex = TodoDetailAttribute.memo.rawValue
                vc.addTodoView.icnView.buttonList[memoAttrIndex].tintColor = (text == nil) ? .gray : .black
            })
            .disposed(by: bag)
        
        output //계속 뺑그르르 돌고있다...
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
                vc.addTodoView.icnView.buttonList[clockAttrIndex].tintColor = (time == nil) ? .gray : .black
                guard let time else { return }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "HH:mm"
                
                let date = dateFormatter.date(from: time)!
                
                vc.addTodoView.clockView.timePicker.date = date
            })
            .disposed(by: bag)
        
        output
            .categoryChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { vc, category in
                if let category {
                    vc.addTodoView.titleView.categoryButton.categoryLabel.text = category.title
                    vc.addTodoView.titleView.categoryButton.categoryLabel.textColor = UIColor(hex: 0x000000)
                    vc.addTodoView.titleView.categoryButton.categoryColorView.backgroundColor = category.color.todoForCalendarColor
                } else {
                    vc.addTodoView.titleView.categoryButton.categoryLabel.text = "카테고리 선택"
                    vc.addTodoView.titleView.categoryButton.categoryLabel.textColor = UIColor(hex: 0xBFC7D7)
                    vc.addTodoView.titleView.categoryButton.categoryColorView.backgroundColor = .gray
                }
                vc.moveFromSelectToAdd()
            })
            .disposed(by: bag)
        
        output
            .groupChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { vc, groupName in
                print("groupName: ", groupName)
                let groupAttrIndex = TodoDetailAttribute.group.rawValue
                vc.addTodoView.icnView.buttonList[groupAttrIndex].tintColor = (groupName == nil) ? .gray : .black
                
                if let groupName {
                    let index = viewModel.groups.firstIndex(of: groupName) ?? 0
                    vc.addTodoView.groupView.groupPickerView.selectRow(index, inComponent: 0, animated: false)
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
                vc.showPopUp(title: "일정, 카테고리는 필수에요", message: "그러나 아무것도 안하는 것도\n충분히 중요한 일이죠 😌", alertAttrs: [CustomAlertAttr(title: "확인", actionHandler: {}, type: .normal)])
            })
            .disposed(by: bag)
        
        
        switch viewModel.mode {
        case .edit:
            self.addTodoView.removeButton.isHidden = false
            self.addTodoView.titleView.todoTitleField.becomeFirstResponder()
        case .new:
            self.addTodoView.removeButton.isHidden = true
            self.addTodoView.titleView.todoTitleField.becomeFirstResponder()
        case .view: break
//            self.addTodoView.contentStackView.isUserInteractionEnabled = false
//            self.dayPickerViewController.view.isHidden = true
//            self.addTodoView.saveButton.isHidden = true
//            self.addTodoView.removeButton.isHidden = true
//            self.addTodoView.contentStackView.snp.remakeConstraints {
//                $0.leading.trailing.equalToSuperview().inset(16)
//                $0.top.equalTo(self.addTodoView.headerBarView.snp.bottom)
//                $0.bottom.equalToSuperview()
//            }
        }
        
        switch viewModel.type {
        case .memberTodo: break
//            self.addTodoView.groupSelectionField.isUserInteractionEnabled = true
        case .socialTodo: break
//            self.addTodoView.groupSelectionField.isUserInteractionEnabled = false
        }
        viewModel.initFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification:NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let newKeyboardBag = DisposeBag()
            keyboardBag = newKeyboardBag
            viewModel?
                .showMessage
                .observe(on: MainScheduler.asyncInstance)
                .withUnretained(self)
                .subscribe(onNext: { vc, message in
                    vc.showToast(message: message.text, type: Message.toToastType(state: message.state), fromBotton: keyboardHeight + 50)
                })
                .disposed(by: newKeyboardBag)
            
            switch pageType {
            case .addTodo:
                dayPickerViewController.view.snp.remakeConstraints {
                    $0.top.equalTo(addTodoView.icnView.snp.bottom)
                    $0.leading.trailing.equalToSuperview().inset(10)
                    $0.height.equalTo(keyboardHeight)
                    $0.bottom.equalToSuperview()
                }
            case .selectCategory:
                return
            case .createCategory:
                categoryCreateView.descLabel.snp.remakeConstraints {
                    $0.top.equalTo(categoryCreateView.collectionView.snp.bottom)
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().inset(keyboardHeight+20)
                }
            }
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(_ notification:NSNotification) {
        let newKeyboardBag = DisposeBag()
        keyboardBag = newKeyboardBag
        viewModel?
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: newKeyboardBag)
        
        switch pageType {
        case .addTodo:
            return
        case .selectCategory:
            return
        case .createCategory:
            categoryCreateView.descLabel.snp.remakeConstraints {
                $0.top.equalTo(categoryCreateView.collectionView.snp.bottom)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(40)
            }
        }
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc func didChangeTime(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateStr = dateFormatter.string(from: sender.date)
        
        didChangedTimeValue.onNext(dateStr)
    }
}

extension TodoDetailViewController: DayPickerViewControllerDelegate {
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDate: Date) {
        addTodoView.dateView.setDate(startDate: dayPickerViewController.dateFormatter2.string(from: didSelectDate))
        didSelectedDateRange.onNext(DateRange(start: didSelectDate))
    }
    
    func unHighlightAllItem(_ dayPickerViewController: DayPickerViewController) {
        addTodoView.dateView.setDate()
        didSelectedDateRange.onNext(DateRange())
    }
    
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDateInRange: (Date, Date)) {
        let (a, b) = didSelectDateInRange
        
        let min = min(a, b)
        let max = max(a, b)
        addTodoView.dateView.setDate(
            startDate: dayPickerViewController.dateFormatter2.string(from: min),
            endDate: dayPickerViewController.dateFormatter2.string(from: max)
        )

        didSelectedDateRange.onNext(DateRange(start: min, end: max))
    }
}

extension TodoDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        didChangednewCategoryColor.onNext(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didChangednewCategoryColor.onNext(nil)
    }
}

extension TodoDetailViewController {
    func moveFromAddToSelect() {
        guard self.pageType != .selectCategory else { return }

        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.addTodoView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.view.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromSelectToCreate() {
        guard self.pageType != .createCategory else { return }

        self.pageType = .createCategory
        categoryCreateView.nameField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view)
                $0.height.lessThanOrEqualTo(800)
                $0.bottom.equalToSuperview()
            }
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.view.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromCreateToSelect() {
        guard self.pageType != .selectCategory else { return }
        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.trailing)
                $0.height.equalTo(500)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromSelectToAdd() {
        guard self.pageType != .addTodo else { return }
        
        self.pageType = .addTodo
        addTodoView.titleView.todoTitleField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.addTodoView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.trailing)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension TodoDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.groups.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.groups[row].groupName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectedGroupAt.onNext(row)
    }
}

extension TodoDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categorys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectCell.reuseIdentifier, for: indexPath) as? CategorySelectCell,
              let viewModel else { return UITableViewCell() }
        
        cell.nameLabel.text = viewModel.categorys[indexPath.row].title
        cell.colorView.backgroundColor = viewModel.categorys[indexPath.row].color.todoForCalendarColor
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            guard let viewModel = self.viewModel else { return }
            let item = viewModel.categorys[indexPath.row]
            guard let id = item.id else { return }
            
            self.categoryCreateView.nameField.text = item.title
            self.categoryCreateView.collectionView.selectItem(at: IndexPath(item: viewModel.categoryColorList.firstIndex(where: { $0 == item.color})!, section: 0), animated: false, scrollPosition: .top)
            
            self.didRequestEditCategoryAt.onNext(id)
            success(true)
        }
        edit.backgroundColor = .systemTeal
        edit.image = UIImage(named: "edit_swipe")
        return UISwipeActionsConfiguration(actions:[edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .normal, title: "Remove") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            guard let categoryId = self.viewModel?.categorys[indexPath.row].id else { return }
            self.viewModel?.categorys.remove(at: indexPath.row)
            self.categoryView.tableView.deleteRows(at: [indexPath], with: .fade)
            self.didDeleteCategoryId.onNext(categoryId)
            success(true)
        }
        remove.backgroundColor = .systemPink
        remove.image = UIImage(named: "remove_swipe")
        return UISwipeActionsConfiguration(actions:[remove])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectCategoryAt.onNext(indexPath.row)
    }
}
// 그냥 높이를 늘였다 줄였다 하는게 나을수도 있을거같음,,, 하씨발 모르것다 ㅋㅋㅋ
extension TodoDetailViewController: TodoDetailIcnViewDelegate {
    func deactivate(attr: TodoDetailAttribute) {
        switch attr {
        case .title:
            addTodoView.titleView.todoTitleField.text = nil
        case .calendar:
            dayPickerViewController.setDate(startDate: nil, endDate: nil)
        case .clock:
            didChangedTimeValue.onNext(nil)
        case .group:
            didSelectedGroupAt.onNext(nil)
        case .memo:
            isMemoActive.onNext(false)
            addTodoView.memoView.memoTextView.text = nil
        }
    }
    
    func move(from: TodoDetailAttribute, to: TodoDetailAttribute) {
        if from != to {
            if to != .title {
                addTodoView.titleView.set1line()
            } else {
                addTodoView.titleView.set2lines()
            }

            
            if from != .title {
                self.addTodoView.attributeViewGroup[from.rawValue].bottomConstraint.isActive = false
            }
            if to != .title {
                let newAnchor = self.addTodoView.attributeViewGroup[to.rawValue].bottomAnchor.constraint(equalTo: self.addTodoView.contentView.bottomAnchor)
                self.addTodoView.attributeViewGroup[to.rawValue].bottomConstraint = newAnchor
                newAnchor.isActive = true
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                if from != .title {
                    self.addTodoView.attributeViewGroup[from.rawValue].alpha = 0
                }
                if to != .title {
                    self.addTodoView.attributeViewGroup[to.rawValue].alpha = 1
                }
            })
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.addTodoView.upperView.layoutIfNeeded()
            })
        }
        
        switch to {
        case .title:
            addTodoView.titleView.todoTitleField.becomeFirstResponder()
        case .calendar:
            self.view.endEditing(true)
        case .clock:
            addTodoView.titleView.todoTitleField.becomeFirstResponder()
            didChangeTime(addTodoView.clockView.timePicker)
        case .group:
            addTodoView.titleView.todoTitleField.becomeFirstResponder()
            let index = addTodoView.groupView.groupPickerView.selectedRow(inComponent: 0)
            didSelectedGroupAt.onNext(index)
        case .memo:
            isMemoActive.onNext(true)
            addTodoView.memoView.memoTextView.becomeFirstResponder()
        }
    }
}
