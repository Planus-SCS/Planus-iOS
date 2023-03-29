//
//  AddTodoViewController.swift
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
        let bottomSheetVC = AddTodoViewController()
        // 1
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        // 2
        self.present(bottomSheetVC, animated: false, completion: nil)
        
    }
}

class AddTodoViewController: UIViewController {
    var pageType: AddTodoViewControllerPageType = .addTodo
    
    
    var didScrolledToIndex = PublishSubject<Double>()

    var viewModel: AddTodoViewModel?
    
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
        self.viewModel?.configureDate(date: Date())

        configureView()
        configureLayout()
        configureAddTodoView()
        configureSelectCategoryView()
        configureCreateCategoryView()
        bind()
    }
    
    func configureAddTodoView() {
        addTodoView.smallCalendarView.smallCalendarCollectionView.dataSource = self
        addTodoView.smallCalendarView.smallCalendarCollectionView.delegate = self
        addTodoView.titleField.delegate = self
        addTodoView.memoTextView.delegate = self
        
        addTodoView.smallCalendarView.prevButton.addTarget(self, action: #selector(prevBtnTapped), for: .touchUpInside)
        addTodoView.smallCalendarView.nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        addTodoView.categoryButton.addTarget(self, action: #selector(categoryBtnTapped), for: .touchUpInside)
    }
    
    func configureSelectCategoryView() {
        categoryView.tableView.dataSource = self
        categoryView.tableView.delegate = self
        categoryView.addNewItemButton.addTarget(self, action: #selector(categoryCreateBtnTapped), for: .touchUpInside)
        categoryView.backButton.addTarget(self, action: #selector(backBtnOnSelectCategoryTapped), for: .touchUpInside)
    }
    
    func configureCreateCategoryView() {
        categoryCreateView.backButton.addTarget(self, action: #selector(backBtnOnCreateCategoryTapped), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addTodoView.titleField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
             self.addTodoView.snp.remakeConstraints {
                 $0.bottom.leading.trailing.equalToSuperview()
                 $0.height.lessThanOrEqualTo(700)
             }
             self.dimmedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
             self.view.layoutIfNeeded()
         }, completion: nil)
    }
    
    @objc func categoryBtnTapped(_ sender: UIButton) {
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
    
    @objc func categoryCreateBtnTapped(_ sender: UIButton) {
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
    
    @objc func backBtnOnCreateCategoryTapped(_ sender: UIButton) {
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
    
    @objc func backBtnOnSelectCategoryTapped(_ sender: UIButton) {
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
    
    func configureView() {
        self.view.addSubview(dimmedView)
        dimmedView.addSubview(addTodoView)
        dimmedView.addSubview(categoryView)
        dimmedView.addSubview(categoryCreateView)
    }
    
    func configureLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addTodoView.snp.makeConstraints {
            $0.leading.width.equalToSuperview()
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
    }

    var bag = DisposeBag()
    
    func bind() {
        guard let viewModel else { return }

        let input = AddTodoViewModel.Input(
            didLoadView: Observable.just(()),
            didChangedIndex: didScrolledToIndex.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didChangedTitleLabel
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, title in
                vc.addTodoView.smallCalendarView.dateLabel.text = title
            })
            .disposed(by: bag)
        
        output
            .didLoadInitDays
            .compactMap { $0 }
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let frameWidth = vc.view.frame.width - 20
                vc.reloadAndMove(to: CGPoint(x: frameWidth * CGFloat(count/2), y: 0))
            })
            .disposed(by: bag)
        
        output
            .didLoadPrevDays
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let exPointX = vc.addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
                let frameWidth = vc.view.frame.width
                vc.reloadAndMove(to: CGPoint(x: exPointX + CGFloat(count)*frameWidth, y: 0))
            })
            .disposed(by: bag)
        
        output
            .didLoadFollowingDays
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let exPointX = vc.addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
                let frameWidth = vc.view.frame.width
                vc.reloadAndMove(to: CGPoint(x: exPointX - CGFloat(count)*frameWidth, y: 0))
            })
            .disposed(by: bag)
    }
    
    func reloadAndMove(to point: CGPoint) {
        addTodoView.smallCalendarView.smallCalendarCollectionView.reloadData()
        addTodoView.smallCalendarView.smallCalendarCollectionView.performBatchUpdates {
            addTodoView.smallCalendarView.smallCalendarCollectionView.setContentOffset(
                point,
                animated: false
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // keyboardWillShow, keyboardWillHide observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //
    @objc func keyboardWillShow(_ notification:NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            switch pageType {
            case .addTodo:
                addTodoView.smallCalendarView.snp.remakeConstraints {
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

            self.view.layoutIfNeeded()

        }
    }


    @objc func keyboardWillHide(_ notification:NSNotification) {
        switch pageType {
        case .addTodo:
            addTodoView.smallCalendarView.snp.remakeConstraints {
                $0.top.equalTo(addTodoView.contentStackView.snp.bottom).offset(12)
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
        self.view.layoutIfNeeded()
    }
}

extension AddTodoViewController: UITableViewDataSource, UITableViewDelegate {
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
            print("edit 클릭 됨")
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
}

extension AddTodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == self.addTodoView.titleField {

            // 원하는 액션 지정하기
            // 엔터 누르기

        }

        return true

    }
}

extension AddTodoViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "메모를 입력하세요"
            textView.textColor = UIColor(hex: 0xBFC7D7)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
}

extension AddTodoViewController {
    @objc func prevBtnTapped(_ sender: UIButton) {
        let exPointX = addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        addTodoView.smallCalendarView.smallCalendarCollectionView.setContentOffset(CGPoint(x: exPointX - frameWidth, y: 0), animated: true)
    }
    
    @objc func nextBtnTapped(_ sender: UIButton) {
        let exPointX = addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        addTodoView.smallCalendarView.smallCalendarCollectionView.setContentOffset(CGPoint(x: exPointX + frameWidth, y: 0), animated: true)
    }
}

extension AddTodoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.viewModel?.days.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel?.days[section].count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DayPickerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? DayPickerCollectionViewCell,
              let viewModel = self.viewModel,
              let currentDate = viewModel.currentDate else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.days[indexPath.section][indexPath.row]
        cell.fill(day: item.dayLabel, state: item.state, isSelectedDay: item.date == currentDate)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if pageType == .addTodo {
            let pointX = scrollView.contentOffset.x
            let frameWidth = addTodoView.smallCalendarView.smallCalendarCollectionView.frame.width
            guard frameWidth != 0 else { return }
            
            let index = pointX/frameWidth
            self.didScrolledToIndex.onNext(index)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if pageType == .addTodo && decelerate {
            DispatchQueue.main.async { [weak self] in
                scrollView.isUserInteractionEnabled = false
                self?.addTodoView.smallCalendarView.prevButton.isUserInteractionEnabled = false
                self?.addTodoView.smallCalendarView.nextButton.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if pageType == .addTodo {
            DispatchQueue.main.async { [weak self] in
                scrollView.isUserInteractionEnabled = true
                self?.addTodoView.smallCalendarView.prevButton.isUserInteractionEnabled = true
                self?.addTodoView.smallCalendarView.nextButton.isUserInteractionEnabled = true
            }
        }
    }
}








