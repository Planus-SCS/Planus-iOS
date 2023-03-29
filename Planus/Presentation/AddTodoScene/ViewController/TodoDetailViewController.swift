//
//  TodoDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift

class VC: UIViewController {
    lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("이걸 눌러", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(action), for: .touchUpInside)

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(100)
        }
        self.view.backgroundColor = .white

    }
    
    @objc func action(_ sender: UIButton) {
        let bottomSheetVC = TodoDetailViewController()
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        self.present(bottomSheetVC, animated: false, completion: nil)
    }
}

class TodoDetailViewController: UIViewController {
    var bag = DisposeBag()

    var didSelectCategoryAt = PublishSubject<Int?>()
    var didRequestEditCategoryAt = PublishSubject<Int>() // 생성도 이걸로하자!
    var didSelectedStartDate = PublishSubject<Date?>()
    var didSelectedEndDate = PublishSubject<Date?>()
    var didSelectedGroupAt = PublishSubject<Int?>()
    var didChangednewCategoryColor = PublishSubject<TodoCategoryColor?>()
    
    var pageType: AddTodoViewControllerPageType = .addTodo

    var viewModel: AddTodoViewModel?
    
    // MARK: Child ViewController
    var dayPickerViewController = DayPickerViewController(nibName: nil, bundle: nil)
    var pickerView = UIPickerView()
    
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
    
    convenience init(viewModel: AddTodoViewModel) {
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
        self.view.backgroundColor = .white

        self.viewModel = AddTodoViewModel()

        configureView()
        configureLayout()

        bind()
    }
    
    func configureAddTodoView() {
        dayPickerViewController.delegate = self
        addTodoView.titleField.delegate = self
        addTodoView.memoTextView.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self
        addTodoView.groupSelectionField.inputView = pickerView
        
        addTodoView.addSubview(dayPickerViewController.view)
        dayPickerViewController.configureDate(date: Date())
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
        addTodoView.titleField.becomeFirstResponder()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
             self.addTodoView.snp.remakeConstraints {
                 $0.bottom.leading.trailing.equalToSuperview()
                 $0.height.lessThanOrEqualTo(700)
             }
             self.dimmedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
             self.view.layoutIfNeeded()
         }, completion: nil)
    }
    
    func configureView() {
        self.view.addSubview(dimmedView)
        dimmedView.addSubview(addTodoView)
        dimmedView.addSubview(categoryView)
        dimmedView.addSubview(categoryCreateView)
        
        configureAddTodoView()
        configureSelectCategoryView()
        configureCreateCategoryView()
    }
    
    func configureLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addTodoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(dimmedView.snp.bottom)
            $0.height.lessThanOrEqualTo(700)
        }
        
        categoryView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalTo(dimmedView.snp.trailing)
            $0.height.equalTo(400)
            $0.bottom.equalToSuperview()
        }
        
        categoryCreateView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalTo(dimmedView.snp.trailing)
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

        let input = AddTodoViewModel.Input(
            todoTitleChanged: addTodoView.titleField.rx.text.asObservable(),
            categorySelected: didSelectCategoryAt.asObservable(),
            startDayChanged: didSelectedStartDate.asObservable(),
            endDayChanged: didSelectedEndDate.asObservable(),
            groupSelected: didSelectedGroupAt.asObservable(),
            memoChanged: addTodoView.memoTextView.rx.text.asObservable(),
            newCategoryNameChanged: categoryCreateView.nameField.rx.text.asObservable(),
            newCategoryColorChanged: didChangednewCategoryColor.asObservable(),
            categoryEditRequested: didRequestEditCategoryAt.asObservable(),
            startDayButtonTapped: addTodoView.startDateButton.rx.tap.asObservable(),
            endDayButtonTapped: addTodoView.endDateButton.rx.tap.asObservable(),
            categorySelectBtnTapped: addTodoView.categoryButton.rx.tap.asObservable(),
            todoSaveBtnTapped: addTodoView.saveButton.rx.tap.asObservable(),
            newCategoryAddBtnTapped: categoryView.addNewItemButton.rx.tap.asObservable(),
            newCategorySaveBtnTapped: categoryCreateView.saveButton.rx.tap.asObservable(),
            categorySelectPageBackBtnTapped: categoryView.backButton.rx.tap.asObservable(),
            categoryCreatePageBackBtnTapped: categoryCreateView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .categoryChanged
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, category in
                if let category {
                    vc.addTodoView.categoryButton.setTitle(category.title, for: .normal)
                    vc.addTodoView.categoryButton.setTitleColor(UIColor(hex: 0x000000), for: .normal)
                    vc.addTodoView.categoryColorView.backgroundColor = category.color.todoLeadingColor
                } else {
                    vc.addTodoView.categoryButton.setTitle("카테고리", for: .normal)
                    vc.addTodoView.categoryButton.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
                    vc.addTodoView.categoryColorView.backgroundColor = .gray
                }
                vc.moveFromSelectToAdd()
            })
            .disposed(by: bag)
        
        output
            .todoSaveBtnEnabled
            .bind(to: addTodoView.saveButton.rx.isEnabled)
            .disposed(by: bag)
        
        output
            .newCategorySaveBtnEnabled
            .bind(to: categoryCreateView.saveButton.rx.isEnabled)
            .disposed(by: bag)
        
        output
            .newCategorySaved
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { vc, _ in
                vc.categoryView.tableView.reloadData()
            }
            .disposed(by: bag)
        
        output
            .moveFromAddToSelect
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.moveFromAddToSelect()
            })
            .disposed(by: bag)
        
        output
            .moveFromSelectToCreate
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.moveFromSelectToCreate()
            })
            .disposed(by: bag)
        
        output
            .moveFromCreateToSelect
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
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.moveFromSelectToAdd()
            })
            .disposed(by: bag)
        
        output
            .removeKeyboard
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.view.endEditing(true)
            })
            .disposed(by: bag)
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
        print(didSelectDate)
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
        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.addTodoView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.dimmedView.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromSelectToCreate() {
        self.pageType = .createCategory
        categoryCreateView.nameField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView)
                $0.height.lessThanOrEqualTo(800)
                $0.bottom.equalToSuperview()
            }
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.dimmedView.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromCreateToSelect() {
        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.trailing)
                $0.height.equalTo(500)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromSelectToAdd() {
        self.pageType = .addTodo
        addTodoView.titleField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.addTodoView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.trailing)
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
        viewModel?.groups.count ?? Int()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel?.groups[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        addTodoView.groupSelectionField.text = viewModel?.groups[row]
        addTodoView.groupSelectionField.textColor = .black
        didSelectedGroupAt.onNext(row)
    }
}

extension TodoDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.categorys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectCell.reuseIdentifier, for: indexPath) as? CategorySelectCell,
              let viewModel else { return UITableViewCell() }
        
        cell.nameLabel.text = viewModel.categorys[indexPath.row].title
        cell.colorView.backgroundColor = viewModel.categorys[indexPath.row].color.todoForCalendarColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            self.categoryCreateView.nameField.text = self.viewModel?.categorys[indexPath.row].title
            self.categoryCreateView.collectionView.selectItem(at: IndexPath(item: self.viewModel!.categorys[indexPath.row].color.rawValue, section: 0), animated: false, scrollPosition: .top)
            self.didRequestEditCategoryAt.onNext(indexPath.row)
            success(true)
        }
        edit.backgroundColor = .systemTeal
        edit.image = UIImage(named: "edit_swipe")
        return UISwipeActionsConfiguration(actions:[edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .normal, title: "Remove") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("remove 클릭 됨")
            self.viewModel?.categorys.remove(at: indexPath.row)
            self.categoryView.tableView.deleteRows(at: [indexPath], with: .fade)
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
        }
        return true
    }
}

extension TodoDetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "메모를 입력하세요"
            textView.textColor = UIColor(hex: 0xBFC7D7)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("here1")
        if textView.textColor == UIColor(hex: 0xBFC7D7) {
            print("here2")
            textView.text = nil
            textView.textColor = .black
        }
    }
}
