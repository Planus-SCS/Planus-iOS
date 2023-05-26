//
//  JoinedGroupCalendarViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import RxSwift

class JoinedGroupCalendarViewController: NestedScrollableViewController {
    
    var bag = DisposeBag()
    var viewModel: JoinedGroupCalendarViewModel?
    
    weak var delegate: JoinedGroupCalendarViewControllerDelegate?
    
    var didChangedMonth = PublishSubject<Date>()
    var didTappedItemAt = PublishSubject<Int>()
    
    var spinner = UIActivityIndicatorView(style: .medium)
    
    lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 80)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        cv.register(DailyCalendarCell.self, forCellWithReuseIdentifier: DailyCalendarCell.identifier)
        cv.register(JoinedGroupDetailCalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: JoinedGroupDetailCalendarHeaderView.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        
        return cv
    }()
    
    convenience init(viewModel: JoinedGroupCalendarViewModel) {
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
    
    func bind() {
        guard let viewModel else { return }
        spinner.isHidden = false
        spinner.startAnimating()
                
        let input = JoinedGroupCalendarViewModel.Input(
            viewDidLoad: Observable.just(()),
            didChangedMonth: didChangedMonth.asObservable(),
            didSelectedAt: didTappedItemAt.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        didChangedMonth
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.spinner.isHidden = false
                vc.spinner.startAnimating()
            })
            .disposed(by: bag)
        
        output
            .didFetchTodo
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.calendarCollectionView.performBatchUpdates({
                    vc.calendarCollectionView.reloadSections(IndexSet(0...0))
                }, completion: { _ in
                    vc.spinner.stopAnimating()
                    vc.spinner.isHidden = true
                })
            })
            .disposed(by: bag)
        
        output
            .showDaily
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, date in
                guard let groupId = vc.viewModel?.groupId,
                      let isOwner = vc.delegate?.isLeader() else { return }
                let nm = NetworkManager()
                let kc = KeyChainManager()
                let tokenRepo = DefaultTokenRepository(apiProvider: nm, keyChainManager: kc)
                let gcr = DefaultGroupCalendarRepository(apiProvider: nm)
                let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
                let refTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
                let fetchGroupDailyTodoListUseCase = DefaultFetchGroupDailyTodoListUseCase(groupCalendarRepository: gcr)
                let viewModel = SocialTodoDailyViewModel(
                    getTokenUseCase: getTokenUseCase,
                    refreshTokenUseCase: refTokenUseCase,
                    fetchGroupDailyTodoListUseCase: fetchGroupDailyTodoListUseCase
                )
                viewModel.setGroup(id: groupId, isOwner: isOwner, date: date)
                
                let viewController = SocialTodoDailyViewController(viewModel: viewModel)
                
                let nav = UINavigationController(rootViewController: viewController)
                nav.modalPresentationStyle = .pageSheet
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
                vc.present(nav, animated: true)
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.addSubview(calendarCollectionView)
        self.view.addSubview(spinner)
        spinner.isHidden = true
    }
    
    func configureLayout() {
        calendarCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        spinner.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(50)
        }
    }
    
}

extension JoinedGroupCalendarViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let maxTodoViewModel = viewModel?.getMaxInWeek(index: indexPath.item) else { return CGSize() }
        
        let screenWidth = UIScreen.main.bounds.width
                
        var todoCount = maxTodoViewModel.todoList.count
        
        if let height = viewModel?.cachedCellHeightForTodoCount[todoCount] {
            return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: Double(height))
            
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * screenWidth, height: 116))
            mockCell.fill(socialTodoList: maxTodoViewModel.todoList)
            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(
                width: Double(1)/Double(7) * screenWidth,
                height: UIView.layoutFittingCompressedSize.height
            ))

            if estimatedSize.height <= 116 {
                viewModel?.cachedCellHeightForTodoCount[todoCount] = 116
                return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: 116)
            } else {
                viewModel?.cachedCellHeightForTodoCount[todoCount] = estimatedSize.height
            
                return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: estimatedSize.height)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        didTappedItemAt.onNext(indexPath.item)
        return false
    }
    

}

extension JoinedGroupCalendarViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.mainDayList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell,
              let dayViewModel = viewModel?.mainDayList[indexPath.item] else {
            return UICollectionViewCell()
        }
        cell.fill(
            day: "\(Calendar.current.component(.day, from: dayViewModel.date))",
            state: dayViewModel.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!
        )
        
        cell.fill(socialTodoList: dayViewModel.todoList)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: JoinedGroupDetailCalendarHeaderView.reuseIdentifier, for: indexPath) as? JoinedGroupDetailCalendarHeaderView else { return UICollectionReusableView() }
        let bag = DisposeBag()
        view.yearMonthButton.setTitle(viewModel?.currentDateText, for: .normal)
        view.yearMonthButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                let dateMonth = vc.viewModel?.currentDate ?? Date()
                let firstMonth = Calendar.current.date(byAdding: DateComponents(month: -100), to: dateMonth) ?? Date()
                let lastMonth = Calendar.current.date(byAdding: DateComponents(month: 500), to: dateMonth) ?? Date()
                
                let vc = MonthPickerViewController(firstYear: firstMonth, lastYear: lastMonth, currentDate: dateMonth) { [weak self] date in
                    self?.didChangedMonth.onNext(date)
                }

                vc.preferredContentSize = CGSize(width: 320, height: 290)
                vc.modalPresentationStyle = .popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = self.view
                popover.sourceItem = view.yearMonthButton
                
                self.present(vc, animated: true, completion:nil)
            })
            .disposed(by: bag)
        view.bag = bag
        return view
    }
}

extension JoinedGroupCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

protocol JoinedGroupCalendarViewControllerDelegate: AnyObject {
    func isLeader() -> Bool?
}
