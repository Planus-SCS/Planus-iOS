//
//  JoinedGroupDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit
import RxSwift
import SnapKit

class JoinedGroupDetailViewController: UIViewController {
    var viewModel: JoinedGroupDetailViewModel?
    
    var headerView = JoinedGroupDetailHeaderView(frame: .zero)
    var headerTabView = JoinedGroupDetailHeaderTabView(frame: .zero)
    var bottomView = UIView(frame: .zero)
    var headerViewHeightConstraint: NSLayoutConstraint?
    
    lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    
    var childList = [UIViewController]()
    
    var noticeViewController: JoinedGroupNoticeViewController?
    var calendarViewController: JoinedGroupCalendarViewController?
    var chatViewController: JoinedGroupChattingViewController?

    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: JoinedGroupDetailViewModel) {
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
        configureView()
        configureLayout()
        configureChild()
        configurePanGesture()
        
        testSetView()
        navigationItem.setLeftBarButton(backButton, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "가보자네카라쿠배배"
    }
    
    @objc func backBtnAction() {
        viewModel?.actions?.pop?()
    }
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: DragDirection = .Up
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
        var dragYDiff : CGFloat

        switch gesture.state {
            
        case .began:
            
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
            
        case .changed:
            
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            dragPreviousY = dragCurrentY
            dragDirection = dragYDiff < 0 ? .Down : .Up
            innerTableViewDidScroll(withDistance: dragYDiff)
            
        case .ended:
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
            
        default: return
        
        }
    }
    
    
    
    func testSetView() {
        headerView.titleImageView.image = UIImage(named: "groupTest1")
        headerView.tagLabel.text = "#태그개수수수수 #네개까지지지지 #제한하는거다다 #어때아무글자텍스트테스트 #오개까지아무글자텍스"
        headerView.memberCountButton.setTitle("4/18", for: .normal)
        headerView.captinButton.setTitle("기정이짱짱", for: .normal)
        headerView.onlineButton.setTitle("4", for: .normal)
        
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
    }

    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)

        self.view.addSubview(headerView)
        self.view.addSubview(bottomView)
        self.view.addSubview(headerTabView)
    }
    
    func configurePanGesture() {
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))

        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(topViewPanGesture)

    }
    
    func configureChild() {
        let noticeViewModel = JoinedGroupNoticeViewModel()
        let noticeViewController = JoinedGroupNoticeViewController(viewModel: noticeViewModel)
        noticeViewController.delegate = self
        self.noticeViewController = noticeViewController
        
        let createMonthlyCalendarUseCase = DefaultCreateMonthlyCalendarUseCase()
        let fetchTodoListUseCase = DefaultReadTodoListUseCase(todoRepository: TestTodoDetailRepository(apiProvider: NetworkManager()))
        let calendarViewModel = JoinedGroupCalendarViewModel(createMonthlyCalendarUseCase: createMonthlyCalendarUseCase, fetchTodoListUseCase: fetchTodoListUseCase)
        let calendarViewController = JoinedGroupCalendarViewController(viewModel: calendarViewModel)
        calendarViewController.delegate = self
        self.calendarViewController = calendarViewController
        
        let chattingViewController = JoinedGroupChattingViewController(nibName: nil, bundle: nil)
        chattingViewController.delegate = self
        self.chatViewController = chattingViewController
        
        childList.append(noticeViewController)
        childList.append(calendarViewController)
        childList.append(chattingViewController)
        
        pageViewController.setViewControllers([childList[0]], direction: .forward, animated: true)

        self.addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        bottomView.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureLayout() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(220)
        }
        
        headerTabView.snp.makeConstraints {
            $0.bottom.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        bottomView.snp.makeConstraints {
            $0.top.equalTo(headerTabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        guard let headerViewHeightConstraint = headerView.constraints.first(where: { $0.firstAttribute == .height }) else { return }
        self.headerViewHeightConstraint = headerViewHeightConstraint
    }
}


extension JoinedGroupDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = childList.firstIndex(where: { $0 == viewController }) {
            if (1..<childList.count).contains(currentViewControllerIndex) {
                return childList[currentViewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = childList.firstIndex(where: { $0 == viewController }) {
            if (0..<(childList.count - 1)).contains(currentViewControllerIndex) {
                return childList[currentViewControllerIndex + 1]
            }
        }
        return nil
    }
}

//MARK:- Delegate Method to tell Inner View Controller movement inside Page View Controller
//Capture it and change the selection bar position in collection View

extension JoinedGroupDetailViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        
        guard let currentVCIndex = childList.firstIndex(where: { $0 == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        
        headerTabView.scrollToTab(index: currentVCIndex)
    }
}

extension JoinedGroupDetailViewController: NestedScrollableViewScrollDelegate {
    
    var currentHeaderHeight: CGFloat? {
        return headerViewHeightConstraint?.constant
    }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        guard let headerViewHeightConstraint else { return }
        headerViewHeightConstraint.constant -= scrollDistance

        if headerViewHeightConstraint.constant < joinedGroupTopViewFinalHeight {
            headerViewHeightConstraint.constant = joinedGroupTopViewFinalHeight
        } else if headerViewHeightConstraint.constant >= joinedGroupTopViewInitialHeight {
            headerViewHeightConstraint.constant = joinedGroupTopViewInitialHeight
        }
    }
//
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        guard let headerViewHeightConstraint else { return }

        let topViewHeight = headerViewHeightConstraint.constant

        /*
         *  Scroll is not restricted.
         *  So this check might cause the view to get stuck in the header height is greater than initial height.

        if topViewHeight >= topViewInitialHeight || topViewHeight <= topViewFinalHeight { return }

        */

        if topViewHeight >= joinedGroupTopViewInitialHeight {
            scrollToInitialView()
        }

    }

    func scrollToInitialView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - joinedGroupTopViewInitialHeight)

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = joinedGroupTopViewInitialHeight

        UIView.animate(withDuration: TimeInterval(time), animations: {

            self.view.layoutIfNeeded()
        })
    }

    func scrollToFinalView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - joinedGroupTopViewFinalHeight)

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = joinedGroupTopViewFinalHeight

        UIView.animate(withDuration: TimeInterval(time), animations: {

            self.view.layoutIfNeeded()
        })
    }
}
