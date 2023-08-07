//
//  TodoDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift

class TodoDetailViewController: UIViewController {
    var keyboardBag: DisposeBag?
    var bag = DisposeBag()
    var completionHandler: (() -> Void)?
    
    var didSelectCategoryAt = PublishSubject<Int?>()
    var didRequestEditCategoryAt = PublishSubject<Int>() // 생성도 이걸로하자!
    var didSelectedDateRange = PublishSubject<DateRange>()
    var didSelectedGroupAt = PublishSubject<Int?>()
    var didChangednewCategoryColor = PublishSubject<CategoryColor?>()
    var didDeleteCategoryId = PublishSubject<Int>()
    var didChangedTimeValue = PublishSubject<String?>()
    
    var pageType: AddTodoViewControllerPageType = .addTodo

    var viewModel: TodoDetailViewModelable?
    
    // MARK: Child ViewController
    var dayPickerViewController = DayPickerViewController(nibName: nil, bundle: nil)
    var groupPickerView = UIPickerView()
    
    // MARK: Child View
    var addTodoView = AddTodoView(frame: .zero)
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
        addTodoView.titleField.delegate = self
        addTodoView.memoTextView.delegate = self
        addTodoView.timeField.delegate = self
        
        groupPickerView.dataSource = self
        groupPickerView.delegate = self
        addTodoView.groupSelectionField.inputView = groupPickerView
        
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
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
             self.addTodoView.snp.remakeConstraints {
                 $0.bottom.leading.trailing.equalToSuperview()
                 $0.height.lessThanOrEqualTo(700)
             }
             self.dimmedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
             self.view.layoutIfNeeded()
         }, completion: nil)
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
            $0.top.equalTo(addTodoView.contentStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview()
        }
        
        self.view.layoutIfNeeded()
    }
    
    func bind() {
        guard let viewModel else { return }

        let input = TodoDetailViewModelableInput( //스킵을 해도 이러는가??
            titleTextChanged: addTodoView.titleField.rx.text.skip(1).asObservable(), //첫번째 값 + becomeFirstResponder 시 값
            categorySelectedAt: didSelectCategoryAt.asObservable(),
            dayRange: didSelectedDateRange.distinctUntilChanged().asObservable(),
            timeFieldChanged: didChangedTimeValue.asObservable(),
            groupSelectedAt: didSelectedGroupAt.distinctUntilChanged().asObservable(),
            memoTextChanged: addTodoView.memoTextView.rx.text.skip(1).asObservable(),
            creatingCategoryNameTextChanged: categoryCreateView.nameField.rx.text.asObservable(),
            creatingCategoryColorChanged: didChangednewCategoryColor.asObservable(),
            didRemoveCategory: didDeleteCategoryId.asObservable(),
            categoryEditRequested: didRequestEditCategoryAt.asObservable(),
            startDayButtonTapped: addTodoView.startDateButton.rx.tap.asObservable(),
            endDayButtonTapped: addTodoView.endDateButton.rx.tap.asObservable(),
            categorySelectBtnTapped: addTodoView.categoryButton.rx.tap.asObservable(),
            todoSaveBtnTapped: addTodoView.saveButton.rx.tap.asObservable(),
            todoRemoveBtnTapped: addTodoView.removeButton.rx.tap.asObservable(),
            newCategoryAddBtnTapped: categoryView.addNewItemButton.rx.tap.asObservable(),
            newCategorySaveBtnTapped: categoryCreateView.saveButton.rx.tap.asObservable(),
            categorySelectPageBackBtnTapped: categoryView.backButton.rx.tap.asObservable(),
            categoryCreatePageBackBtnTapped: categoryCreateView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output
            .titleValueChanged
            .bind(to: addTodoView.titleField.rx.text)
            .disposed(by: bag)
        
        output
            .memoValueChanged
            .bind(to: addTodoView.memoTextView.rx.text)
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
            .subscribe(onNext: { [weak self] time in
                self?.addTodoView.timeField.text = time
            })
            .disposed(by: bag)
        
        output
            .categoryChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { vc, category in
                if let category {
                    vc.addTodoView.categoryButton.setTitle(category.title, for: .normal)
                    vc.addTodoView.categoryButton.setTitleColor(UIColor(hex: 0x000000), for: .normal)
                    vc.addTodoView.categoryColorView.backgroundColor = category.color.todoForCalendarColor
                } else {
                    vc.addTodoView.categoryButton.setTitle("카테고리", for: .normal)
                    vc.addTodoView.categoryButton.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
                    vc.addTodoView.categoryColorView.backgroundColor = .systemGray2
                }
                vc.moveFromSelectToAdd()
            })
            .disposed(by: bag)
        
        output
            .groupChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { vc, groupName in
                vc.addTodoView.groupSelectionField.text = groupName?.groupName
            })
            .disposed(by: bag)
        
        output
            .todoSaveBtnEnabled
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { vc, isEnabled in
                vc.addTodoView.saveButton.isEnabled = isEnabled
                vc.addTodoView.saveButton.alpha = isEnabled ? 1.0 : 0.5
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
        
        
        switch viewModel.mode {
        case .edit:
            self.addTodoView.removeButton.isHidden = false
            self.addTodoView.titleField.becomeFirstResponder()
        case .new:
            self.addTodoView.removeButton.isHidden = true
            self.addTodoView.titleField.becomeFirstResponder()
        case .view:
            self.addTodoView.contentStackView.isUserInteractionEnabled = false
            self.dayPickerViewController.view.isHidden = true
            self.addTodoView.saveButton.isHidden = true
            self.addTodoView.removeButton.isHidden = true
            self.addTodoView.contentStackView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.top.equalTo(self.addTodoView.headerBarView.snp.bottom)
                $0.bottom.equalToSuperview()
            }
        }
        
        switch viewModel.type {
        case .memberTodo:
            self.addTodoView.groupSelectionField.isUserInteractionEnabled = true
        case .socialTodo:
            self.addTodoView.groupSelectionField.isUserInteractionEnabled = false
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
                    $0.top.equalTo(addTodoView.contentStackView.snp.bottom)
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
            dayPickerViewController.view.snp.remakeConstraints {
                $0.top.equalTo(addTodoView.contentStackView.snp.bottom)
                $0.leading.trailing.equalToSuperview().inset(10)
                $0.height.equalTo(300)
                $0.bottom.equalToSuperview()
            }
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
        })    }
}

extension TodoDetailViewController: DayPickerViewControllerDelegate {
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDate: Date) {
        addTodoView.startDateButton.setTitle("\(dayPickerViewController.dateFormatter2.string(from: didSelectDate))", for: .normal)
        addTodoView.startDateButton.setTitleColor(.black, for: .normal)
        addTodoView.dateArrowView.image = UIImage(named: "arrow_white")
        addTodoView.endDateButton.setTitle("2000.00.00", for: .normal)
        addTodoView.endDateButton.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        didSelectedDateRange.onNext(DateRange(start: didSelectDate))
    }
    
    func unHighlightAllItem(_ dayPickerViewController: DayPickerViewController) {
        addTodoView.startDateButton.setTitle("2000.00.00", for: .normal)
        addTodoView.startDateButton.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        addTodoView.dateArrowView.image = UIImage(named: "arrow_white")
        addTodoView.endDateButton.setTitle("2000.00.00", for: .normal)
        addTodoView.endDateButton.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        didSelectedDateRange.onNext(DateRange())
    }
    
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDateInRange: (Date, Date)) {
        let a = didSelectDateInRange.0
        let b = didSelectDateInRange.1
        
        let min = min(a, b)
        let max = max(a, b)
        
        addTodoView.startDateButton.setTitle("\(dayPickerViewController.dateFormatter2.string(from: min))", for: .normal)
        addTodoView.startDateButton.setTitleColor(.black, for: .normal)
        addTodoView.dateArrowView.image = UIImage(named: "arrow_dark")
        addTodoView.endDateButton.setTitle("\(dayPickerViewController.dateFormatter2.string(from: max))", for: .normal)
        addTodoView.endDateButton.setTitleColor(.black, for: .normal)
        print("didSelect Multiple")
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
        addTodoView.titleField.becomeFirstResponder()
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

// 달력에서 데일리 여는건 의존성이 약간 있을수밖에없음. 근데 투두 생성은 걍 개씹 별개로 가져가는게 맞음. 즉 내가 가입한 그룹이나, 내 카테고리 등을 유즈케이스로 가져와야함
// 달력 -> 데일리 : date, todoList, categoryDict, groupDict를 전부 전달(이것도 맞는건지는 모르겠네,,,)
// 투두 생성 : 카테고리 유즈케이스나 그룹 유즈케이스에서 읽어와야한다..!

extension TodoDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (viewModel?.groups.count ?? 0) + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "그룹 선택"
        }
        return viewModel?.groups[row-1].groupName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            addTodoView.groupSelectionField.text = nil
            return
        }
        didSelectedGroupAt.onNext(row-1)
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

extension TodoDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.addTodoView.titleField {
            self.addTodoView.memoTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.addTodoView.timeField {
            let separator: Character = ":"
            if string == "" { //backspace
                if var textString = textField.text,
                   !textString.isEmpty {
                    textString = textString.replacingOccurrences(of: String(separator), with: "")
                    textString = String(textString.dropLast())
                    if textString.count >= 2 {
                        textString.insert(separator, at: textString.index(textString.startIndex, offsetBy: 2)
)
                    }
                    textField.text = textString
                    didChangedTimeValue.onNext(textString)
                }
                return false
            } else if var textString = textField.text {
                if textString.contains(separator) {
                    textString = textString.replacingOccurrences(of: String(separator), with: "")
                }
                
                if textString.count == 4 {
                    return false
                }
                textString += string

                if textString.count >= 2 {
                    textString.insert(separator, at: textString.index(textString.startIndex, offsetBy: 2))
                }
                textField.text = textString
                didChangedTimeValue.onNext(textString)

                return false
            }
        }
        return true
    }
}

extension TodoDetailViewController: UITextViewDelegate {
}
