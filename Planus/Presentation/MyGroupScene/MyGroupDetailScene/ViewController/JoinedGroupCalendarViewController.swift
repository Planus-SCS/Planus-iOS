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
        cv.showsVerticalScrollIndicator = false

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
                let fetchGroupDailyTodoListUseCase = DefaultFetchGroupDailyCalendarUseCase(groupCalendarRepository: gcr)
                let fetchMemberDailyCalendarUseCase = DefaultFetchGroupMemberDailyCalendarUseCase(memberCalendarRepository: DefaultGroupMemberCalendarRepository(apiProvider: nm))
                let viewModel = SocialTodoDailyViewModel(
                    getTokenUseCase: getTokenUseCase,
                    refreshTokenUseCase: refTokenUseCase,
                    fetchGroupDailyTodoListUseCase: fetchGroupDailyTodoListUseCase,
                    fetchMemberDailyCalendarUseCase: fetchMemberDailyCalendarUseCase
                )
                viewModel.setGroup(groupId: groupId, type: .group(isLeader: isOwner), date: date)
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
        guard let viewModel else { return CGSize() }

        let screenWidth = UIScreen.main.bounds.width
        
        if indexPath.item%7 == 0 {
            (indexPath.item..<indexPath.item + 7).forEach { //해당주차의 blockMemo를 전부 0으로 초기화
                viewModel.blockMemo[$0] = [Int?](repeating: nil, count: 20)
            }

            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            for (item, dayViewModel) in Array(viewModel.mainDayList.enumerated())[indexPath.item..<indexPath.item+7] {
                var filteredTodoList = viewModel.todos[dayViewModel.date] ?? []
                
                var periodList = filteredTodoList.filter { $0.startDate != $0.endDate }
                let singleList = filteredTodoList.filter { $0.startDate == $0.endDate }
                
                if item % 7 != 0 { // 만약 월요일이 아닐 경우, 오늘 시작하는것들만, 월요일이면 포함되는 전체 다!
                    periodList = periodList.filter { $0.startDate == dayViewModel.date }
                        .sorted { $0.endDate < $1.endDate }
                } else { //월요일 중에 오늘이 startDate가 아닌 놈들만 startDate로 정렬, 그 뒤에는 전부다 endDate로 정렬하고, 이걸 다시 endDate를 업댓해줘야함!
                    
                    var continuousPeriodList = periodList
                        .filter { $0.startDate != dayViewModel.date }
                        .sorted{ ($0.startDate == $1.startDate) ? $0.endDate < $1.endDate : $0.startDate < $1.startDate }
                        .map { todo in
                            var tmpTodo = todo
                            tmpTodo.startDate = dayViewModel.date
                            return tmpTodo
                        }
                    
                    var initialPeriodList = periodList
                        .filter { $0.startDate == dayViewModel.date } //이걸 바로 end로 정렬해도 되나? -> 애를 바로 end로 정렬할 경우?
                        .sorted{ $0.endDate < $1.endDate }
                    
                    periodList = continuousPeriodList + initialPeriodList
                }
                
                periodList = periodList.map { todo in
                    let currentWeek = calendar.component(.weekOfYear, from: dayViewModel.date)
                    let endWeek = calendar.component(.weekOfYear, from: todo.endDate)
                    
                    if currentWeek != endWeek {
                        let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dayViewModel.date))
                        let lastDayOfWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfWeek!) //이게 이번주 일요일임.
                        var tmpTodo = todo
                        tmpTodo.endDate = lastDayOfWeek!
                        return tmpTodo
                    } else { return todo }
                }
                
                let periodTodo: [(Int, SocialTodoSummary)] = periodList.compactMap { todo in
                    for i in (0..<viewModel.blockMemo[item].count) {
                        if viewModel.blockMemo[item][i] == nil,
                           let period = Calendar.current.dateComponents([.day], from: todo.startDate, to: todo.endDate).day {
                            for j in (0...period) {
                                viewModel.blockMemo[item+j][i] = todo.todoId
                            }
                            return (i, todo)
                        }
                    }
                    return nil
                }
                
                var singleStartIndex = 0
                viewModel.blockMemo[item].enumerated().forEach { (index, tuple) in
                    if tuple != nil {
                        singleStartIndex = index + 1
                    }
                }
                
                let singleTodo = singleList.enumerated().map { (index, todo) in
                    return (index + singleStartIndex, todo)
                }
                
                var holidayMock: (Int, String)?
                if let holidayTitle = HolidayPool.shared.holidays[dayViewModel.date] {
                    let holidayIndex = singleStartIndex + singleTodo.count
                    holidayMock = (holidayIndex, holidayTitle)
                }
                
                viewModel.filteredTodoCache[item] = FilteredSocialTodoViewModel(periodTodo: periodTodo, singleTodo: singleTodo, holiday: holidayMock)
            }
        }
        
        let weekRange = (indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7)
        
        guard let maxItem = viewModel.filteredTodoCache[weekRange]
            .max(by: { a, b in
                let aHeight = (a.holiday != nil) ? a.holiday!.0 : (a.singleTodo.last != nil) ?
                a.singleTodo.last!.0 : (a.periodTodo.last != nil) ? a.periodTodo.last!.0 : 0
                let bHeight = (b.holiday != nil) ? b.holiday!.0 : (b.singleTodo.last != nil) ?
                b.singleTodo.last!.0 : (b.periodTodo.last != nil) ? b.periodTodo.last!.0 : 0
                return aHeight < bHeight
            }) else { return CGSize() }
                
        guard var todosHeight = (maxItem.holiday != nil) ?
                maxItem.holiday?.0 : (maxItem.singleTodo.count != 0) ?
                maxItem.singleTodo.last?.0 : (maxItem.periodTodo.count != 0) ?
                maxItem.periodTodo.last?.0 : 0 else { return CGSize() }
        
        if let cellHeight = viewModel.cachedCellHeightForTodoCount[todosHeight] {
            return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: cellHeight)
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * screenWidth, height: 116))
            mockCell.socialFill(periodTodoList: maxItem.periodTodo, singleTodoList: maxItem.singleTodo, holiday: maxItem.holiday)
            
            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(
                width: Double(1)/Double(7) * screenWidth,
                height: UIView.layoutFittingCompressedSize.height
            ))
            
            let targetHeight = (estimatedSize.height > 116) ? estimatedSize.height : 116
            viewModel.cachedCellHeightForTodoCount[todosHeight] = targetHeight
            return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: targetHeight)
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
        guard let viewModel,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell else {
            return UICollectionViewCell()
        }
        
        let dayViewModel = viewModel.mainDayList[indexPath.item]
        let filteredTodo = viewModel.filteredTodoCache[indexPath.item]
        
        cell.fill(
            day: "\(Calendar.current.component(.day, from: dayViewModel.date))",
            state: dayViewModel.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!,
            isToday: dayViewModel.date == viewModel.today,
            isHoliday: HolidayPool.shared.holidays[dayViewModel.date] != nil
        )
        
        cell.socialFill(periodTodoList: filteredTodo.periodTodo, singleTodoList: filteredTodo.singleTodo, holiday: filteredTodo.holiday)

        
        
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
