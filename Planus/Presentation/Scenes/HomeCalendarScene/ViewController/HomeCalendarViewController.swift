//
//  HomeCalendarViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeCalendarViewController: UIViewController {
    
    private var bag = DisposeBag()
    
    private var homeCalendarView: HomeCalendarView?
    private var viewModel: HomeCalendarViewModel?
    
    // MARK: - UI Event
    private let isMonthChanged = PublishRelay<Date>()
    private let nowMultipleSelecting = PublishRelay<Bool>()
    private let multipleItemSelected = PublishRelay<(IndexPath, IndexPath)>()
    private let itemSelected = PublishRelay<IndexPath>()
    private let isGroupSelectedWithId = PublishRelay<Int?>()
    private let refreshRequired = PublishRelay<Void>()
    private let didFetchRefreshedData = PublishRelay<Void>()
    private let movedToIndex = PublishRelay<HomeCalendarViewModel.CalendarMovable>()
    
    private var observeScroll = false
        
    convenience init(viewModel: HomeCalendarViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
}

// MARK: - Configure
private extension HomeCalendarViewController {
    func configureVC() {
        guard let homeCalendarView else { return }
        
        homeCalendarView.collectionView.delegate = self
        homeCalendarView.collectionView.dataSource = self
    }
    
    func configureNavigationBar() {
        guard let homeCalendarView else { return }
        
        self.navigationItem.titleView = homeCalendarView.yearMonthButton
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: homeCalendarView.profileButton), animated: false)
    }
    
    func configureView() {
        let view = HomeCalendarView(frame: self.view.frame)
        self.view = view
        self.homeCalendarView = view
    }
}

// MARK: - bind viewModel
private extension HomeCalendarViewController {
    func bind() {
        guard let viewModel,
              let homeCalendarView else { return }
  
        let createPeriodTodoCompletionHandler = { indexPath in
            guard let cell = homeCalendarView.collectionView.cellForItem(
                at: indexPath
            ) as? MonthlyCalendarCell else { return }
            cell.deselectItems()
        }
        
        nowMultipleSelecting
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { bool in
                homeCalendarView.collectionView.isScrollEnabled = !bool
                homeCalendarView.collectionView.isUserInteractionEnabled = !bool
            })
            .disposed(by: bag)
        
        let input = HomeCalendarViewModel.Input(
            viewDidLoaded: Observable.just(()),
            movedToIndex: movedToIndex.asObservable(),
            itemSelectedAt: itemSelected.asObservable(),
            multipleItemSelectedInRange: multipleItemSelected.asObservable(),
            titleBtnTapped: homeCalendarView.yearMonthButton.rx.tap.asObservable(),
            monthSelected: isMonthChanged.asObservable(),
            filterGroupWithId: isGroupSelectedWithId.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            profileBtnTapped: homeCalendarView.profileButton.rx.tap.asObservable(),
            createPeriodTodoCompletionHandler: createPeriodTodoCompletionHandler
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .dateTitleUpdated
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, text in
                homeCalendarView.yearMonthButton.setTitle(text, for: .normal)
            }
            .disposed(by: bag)
        
        output
            .needMoveTo
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, type in
                switch type {
                case .initialized(let index):
                    vc.initializeToIndex(centerIndex: index)
                case .jump(let index):
                    vc.jumpToIndex(index: index)
                default:
                    return
                }
            }
            .disposed(by: bag)
        
        output.showMonthPicker
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, args in
                vc.showMonthPicker(
                    firstYear: args.first,
                    current: args.current,
                    lastYear: args.last
                )
            })
            .disposed(by: bag)
        
        output
            .reloadSectionSet
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, type in
                switch type {
                case .internalChange(let indexSet):
                    UIView.performWithoutAnimation {
                        homeCalendarView.collectionView.reloadSections(indexSet)
                    }
                case .apiFetched(let indexSet):
                    homeCalendarView.collectionView.reloadSections(indexSet)
                }
            })
            .disposed(by: bag)
        
        output.profileImageFetched
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                homeCalendarView.profileButton.fill(with: data)
            })
            .disposed(by: bag)
        
        output.showAlert
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: bag)
        
        output
            .groupListFetched
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, groups in
                vc.setGroupButton(groups: groups)
            })
            .disposed(by: bag)
        
        output
            .didFinishRefreshing
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.didFetchRefreshedData.accept(())
            })
            .disposed(by: bag)
                    
    }
}

// MARK: Calendar Move Actions
private extension HomeCalendarViewController {
    func jumpToIndex(index: Int) {
        guard let homeCalendarView else { return }
        
        observeScroll = false
        homeCalendarView.collectionView.contentOffset = CGPoint(x: CGFloat(index) * view.frame.width, y: 0)
        observeScroll = true
        movedToIndex.accept(.jump(index))
    }
    
    func initializeToIndex(centerIndex: Int) {
        guard let homeCalendarView else { return }
        
        homeCalendarView.collectionView.performBatchUpdates({
            homeCalendarView.collectionView.reloadData()
        }, completion: { [weak self] _ in
            guard let self else { return }
            homeCalendarView.collectionView.contentOffset = CGPoint(x: CGFloat(centerIndex) * self.view.frame.width, y: 0)
            homeCalendarView.collectionView.setAnimatedIsHidden(false, duration: 0.1)

            self.observeScroll = true
            movedToIndex.accept(.initialized(centerIndex))
        })
    }
}

// MARK: - Setting Group
private extension HomeCalendarViewController {
    func setGroupButton(groups: [GroupName]) {
        let image = UIImage(named: "groupCalendarList")
        let allAction = createGroupAction(title: "모아 보기", groupId: nil)
        let groupActions = groups.map { group in
            createGroupAction(title: group.groupName, groupId: group.groupId)
        }
        
        let buttonMenu = UIMenu(options: .displayInline, children: [allAction] + groupActions)
        
        let item = UIBarButtonItem(image: image, menu: buttonMenu)
        item.tintColor = .planusBlack
        navigationItem.setLeftBarButton(item, animated: true)
        homeCalendarView?.groupListButton = item
    }

    func createGroupAction(title: String, groupId: Int?) -> UIAction {
        UIAction(title: title) { [weak self] _ in
            self?.isGroupSelectedWithId.accept(groupId)
        }
    }
}

// MARK: - show VC
private extension HomeCalendarViewController {
    func showMonthPicker(firstYear: Date, current: Date, lastYear: Date) {
        guard let homeCalendarView else { return }
        
        let vc = MonthPickerViewController(firstYear: firstYear, lastYear: lastYear, currentDate: current) { [weak self] date in
            self?.isMonthChanged.accept(date)
        }

        vc.preferredContentSize = CGSize(width: 320, height: 290)
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        let globalFrame = homeCalendarView.yearMonthButton.convert(homeCalendarView.yearMonthButton.bounds, to: nil)
        popover.sourceRect = CGRect(x: globalFrame.midX, y: globalFrame.maxY, width: 0, height: 0)
        popover.permittedArrowDirections = [.up]
        self.present(vc, animated: true, completion:nil)
    }
}

// MARK: - CollectionView DataSource, Delegate
extension HomeCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.mainDays.count ?? Int()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MonthlyCalendarCell.reuseIdentifier,
            for: indexPath
        ) as? MonthlyCalendarCell,
              let viewModel else { return UICollectionViewCell() }
        
        cell.fill(
            section: indexPath.section,
            viewModel: viewModel
        )

        cell.fill(
            nowMultipleSelecting: nowMultipleSelecting,
            multipleItemSelected: multipleItemSelected,
            itemSelected: itemSelected,
            refreshRequired: refreshRequired,
            didFetchRefreshedData: didFetchRefreshedData
        )
            
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let floatedIndex = scrollView.contentOffset.x/scrollView.bounds.width
        guard !(floatedIndex.isNaN || floatedIndex.isInfinite) && observeScroll else { return }
        movedToIndex.accept(.scroll(Int(round(floatedIndex))))
    }
}

// MARK: - PopoverPresentationDelegate
extension HomeCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

