//
//  CategorySelectViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift
import RxCocoa

final class CategorySelectViewController: UIViewController {
    private let bag = DisposeBag()
    private var viewModel: (any CategorySelectViewModelable)?
    
    // MARK: UI Event
    private let categorySelectedAt = PublishRelay<Int>()
    private let categoryEditRequiredWithId = PublishRelay<Int>()
    private let categoryRemoveRequiredWithId = PublishRelay<Int>()
    private let needDismiss = PublishRelay<Void>()

    // MARK: Child View
    private let categoryView = CategorySelectView(frame: .zero)
    
    // MARK: Background
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        return view
    }()
    
    convenience init(viewModel: any CategorySelectViewModelable) {
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
        
        configureVC()
        configureView()
        configureLayout()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

// MARK: - bind viewModel
private extension CategorySelectViewController {
    func bind() {
        guard let viewModel else { return }
        
        let input = (any CategorySelectViewModelable).Input(
            categorySelectedAt: categorySelectedAt.asObservable(),
            categoryEditRequiredWithId: categoryEditRequiredWithId.asObservable(),
            categoryRemoveRequiredWithId: categoryRemoveRequiredWithId.asObservable(),
            categoryCreateBtnTapped: categoryView.addNewItemButton.rx.tap.asObservable(),
            backBtnTapped: categoryView.backButton.rx.tap.asObservable(),
            needDismiss: needDismiss.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .insertCategoryAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.categoryView.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .left)
            })
            .disposed(by: bag)
        
        output
            .reloadCategoryAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.categoryView.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            })
            .disposed(by: bag)
        
        output
            .removeCategoryAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.categoryView.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: bag)
        
    }
}

// MARK: - configure
private extension CategorySelectViewController {
    func configureVC() {
        configureSelectCategoryView()
        configureDimmedView()
    }
    func configureSelectCategoryView() {
        categoryView.tableView.dataSource = self
        categoryView.tableView.delegate = self
    }
    
    func configureDimmedView() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(_:)))
        dimmedView.addGestureRecognizer(dimmedTap)
        dimmedView.isUserInteractionEnabled = true
    }
    
    func configureView() {
        self.view.addSubview(dimmedView)
        self.view.addSubview(categoryView)
    }
    
    func configureLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        categoryView.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(400)
        }
    }
}

private extension CategorySelectViewController {
    @objc
    func dimmedViewTapped(_ sender: UITapGestureRecognizer) {
        animateDismiss()
    }
    
    func animateDismiss() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.dimmedView.alpha = 0.0
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.height.equalTo(400)
                $0.top.equalTo(self.dimmedView.snp.bottom)
            }
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.needDismiss.accept(())
        })
    }
}

// MARK: - TableView
extension CategorySelectViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectCell.reuseIdentifier, for: indexPath) as? CategorySelectCell,
              let viewModel else { return UITableViewCell() }
        
        cell.nameLabel.text = viewModel.categories[indexPath.row].title
        cell.colorView.backgroundColor = viewModel.categories[indexPath.row].color.todoForCalendarColor
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            guard let viewModel = self.viewModel else { return }
            let item = viewModel.categories[indexPath.row]
            guard let id = item.id else { return }
            self.categoryEditRequiredWithId.accept(id)
            success(true)
        }
        edit.backgroundColor = .systemTeal
        edit.image = UIImage(named: "edit_swipe")
        return UISwipeActionsConfiguration(actions:[edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .normal, title: "Remove") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            guard let viewModel = self.viewModel else { return }
            let item = viewModel.categories[indexPath.row]
            guard let id = item.id else { return }
            self.categoryRemoveRequiredWithId.accept(id)
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
        self.categorySelectedAt.accept(indexPath.item)
    }
}
