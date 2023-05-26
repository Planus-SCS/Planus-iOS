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
    
    var didChangedMonth = PublishSubject<Date>()
    var didSelectedAt = PublishSubject<Int>()
    
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
        
        let input = JoinedGroupCalendarViewModel.Input(
            viewDidLoad: Observable.just(()),
            didChangedMonth: didChangedMonth.asObservable(),
            didSelectedAt: didSelectedAt.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didCreateCalendar
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.calendarCollectionView.reloadData()
            })
            .disposed(by: bag)
        
        output
            .didFetchTodo
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.calendarCollectionView.reloadData()
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.addSubview(calendarCollectionView)
    }
    
    func configureLayout() {
        calendarCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

extension JoinedGroupCalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let maxTodoViewModel = viewModel?.getMaxInWeek(index: indexPath.item) else { return CGSize() }
        
        let screenWidth = UIScreen.main.bounds.width
                
        var todoCount = maxTodoViewModel.todoList.count
        
        if let height = viewModel?.cachedCellHeightForTodoCount[todoCount] {
            return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: Double(height))
            
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * screenWidth, height: 116))
            mockCell.fill(todoList: maxTodoViewModel.todoList)
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
            print("여긴가1?")
            return UICollectionViewCell()
        }
        
        cell.fill(
            delegate: self,
            day: "\(Calendar.current.component(.day, from: dayViewModel.date))",
            state: dayViewModel.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!,
            todoList: dayViewModel.todoList
        )

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: JoinedGroupDetailCalendarHeaderView.reuseIdentifier, for: indexPath) as? JoinedGroupDetailCalendarHeaderView else { return UICollectionReusableView() }
        return view
    }
}

extension JoinedGroupCalendarViewController: DailyCalendarCellDelegate {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId: Int) -> CategoryColor? {
        // 컬러담당하는 놈이 필요하다..! 뷰모델에서 갖고오자..!
        // 원래 데일리는 이걸 썼음. 근데 지금은 id로 넘겨주질 않고있음. 즉 아에 싹바뀐거임..!
        return CategoryColor.blue
    }
}

/*
 업데이트를 어떻게 해야하지???
 */
