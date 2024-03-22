//
//  SocialDailyCalendarViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import UIKit
import RxSwift

class SocialDailyCalendarViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: SocialDailyCalendarViewModel?
    
    var didDeleteTodoAt = PublishSubject<IndexPath>()
    
    var spinner = UIActivityIndicatorView(style: .medium)

    lazy var dateTitleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var addTodoButton: UIBarButtonItem = {
        let image = UIImage(named: "plusBtn")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    lazy var collectionView: DailyCalendarCollectionView = {
        let cv = DailyCalendarCollectionView(frame: .zero)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    convenience init(viewModel: SocialDailyCalendarViewModel) {
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
        navigationItem.titleView = dateTitleButton
        
        navigationController?.presentationController?.delegate = self
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = SocialDailyCalendarViewModel.Input(
            viewDidLoad: Observable.just(()),
            addTodoTapped: addTodoButton.rx.tap.asObservable(),
            didSelectTodoAt: collectionView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
                
        spinner.isHidden = false
        spinner.startAnimating()
        collectionView.setAnimatedIsHidden(true, duration: 0)
        
        output
            .didFetchTodoList
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.collectionView.reloadData()
                vc.spinner.setAnimatedIsHidden(true, duration: 0.2, onCompletion: {
                    vc.spinner.stopAnimating()
                    vc.collectionView.setAnimatedIsHidden(false, duration: 0.2)
                })
            })
            .disposed(by: bag)
        
        dateTitleButton.setTitle(output.currentDateText, for: .normal)

        guard let type = output.socialType else { return }
        
        switch type {
        case .member(let id):
            navigationItem.setRightBarButton(nil, animated: false)
        case .group(let isLeader):
            navigationItem.setRightBarButton((isLeader ?? false) ? addTodoButton : nil, animated: false)
        }
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(collectionView)
        self.view.addSubview(spinner)
    }
    
    func configureLayout() {
        dateTitleButton.snp.makeConstraints {
            $0.width.equalTo(160)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        spinner.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(50)
        }
    }
        
}

extension SocialDailyCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            let count = viewModel?.scheduledTodoList?.count ?? 0
            return count == 0 ? 1 : count
        case 1:
            let count = viewModel?.unscheduledTodoList?.count ?? 0
            return count == 0 ? 1 : count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var todoItem: SocialTodoDaily?
        
        switch indexPath.section {
        case 0:
            if let scheduledList = viewModel?.scheduledTodoList,
               !scheduledList.isEmpty {
                todoItem = scheduledList[indexPath.item]
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarEmptyTodoMockCell.reuseIdentifier, for: indexPath)
            }
        case 1:
            if let unscheduledList = viewModel?.unscheduledTodoList,
               !unscheduledList.isEmpty {
                todoItem = unscheduledList[indexPath.item]
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarEmptyTodoMockCell.reuseIdentifier, for: indexPath)
            }
        default: return UICollectionViewCell()
        }
        guard let todoItem else { return UICollectionViewCell() }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarTodoCell.reuseIdentifier, for: indexPath) as? DailyCalendarTodoCell else {
            return UICollectionViewCell()
        }
        cell.fill(
            title: todoItem.title,
            time: todoItem.startTime,
            category: todoItem.categoryColor,
            isGroup: todoItem.isGroupTodo,
            isScheduled: todoItem.isPeriodTodo,
            isMemo: todoItem.hasDescription,
            completion: todoItem.isCompleted,
            isOwner: false
        )
        
        return cell
        

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: DailyCalendarCollectionView.headerKind, withReuseIdentifier: DailyCalendarSectionHeaderSupplementaryView.reuseIdentifier, for: indexPath) as? DailyCalendarSectionHeaderSupplementaryView else { return UICollectionReusableView() }
        
        var title: String
        switch indexPath.section {
        case 0:
            title = "일정"
        case 1:
            title = "할일"
        default:
            return UICollectionReusableView()
        }
        headerview.fill(title: title)
     
        return headerview
    }
    
}

extension SocialDailyCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension SocialDailyCalendarViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel?.actions.finishScene?()
    }
}
