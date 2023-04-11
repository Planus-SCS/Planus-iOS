//
//  TodoMainViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift

class TodoMainViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: TodoMainViewModel?
    
    var didSelectItem = PublishSubject<IndexPath>()
    var didSelectDay = PublishSubject<Date>()
    
    var collectionView = TodoDailyCollectionView(frame: .zero)
    
    lazy var dateTitleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setImage(UIImage(named: "downButton"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(dateTitleBtnTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var addTodoButton: UIBarButtonItem = {
        let image = UIImage(named: "plusBtn")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addTodoTapped))
        
        item.tintColor = UIColor(hex: 0x000000)
        return item
    }()
    
    @objc func addTodoTapped(_ sender: UIButton) {
        print("tap!")
    }
    
    convenience init(viewModel: TodoMainViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel

    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Never init with storyboard")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureView()
        configureLayout()

        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.titleView = dateTitleButton
        self.navigationItem.setRightBarButton(addTodoButton, animated: false)
    }
    
    private func bind() {
        guard let viewModel else { return }
        
        let input = TodoMainViewModel.Input(
            didSelectItem: didSelectItem.asObservable(),
            didTappedTitleButton: dateTitleButton.rx.tap.asObservable(),
            didSelectDay: didSelectDay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.didLoadYYYYMMDD
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, text in
                vc.dateTitleButton.setTitle(text, for: .normal)
            })
            .disposed(by: bag)
        
        
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(collectionView)
    }
    
    func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc func dateTitleBtnTapped(_ sender: UIButton) {
//        showSmallCalendar()
    }
    
//    private func showSmallCalendar() {
//        guard let viewModel = self.viewModel,
//              let currentDate = try? viewModel.currentDate.value() else {
//            return
//        }
//
//        let vm = SmallCalendarViewModel()
//        vm.configureDate(date: currentDate)
//        let vc = SmallCalendarViewController(viewModel: vm)
//
//        vc.preferredContentSize = CGSize(width: 320, height: 400)
//        vc.modalPresentationStyle = .popover
//
//        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = self.view
//        popover.sourceItem = dateTitleButton
//
//        present(vc, animated: true, completion:nil)
//    }
}

//extension TodoMainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        viewModel?.mainDayList.count ?? Int()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoDailyCalendarCell.reuseIdentifier, for: indexPath) as? TodoDailyCalendarCell else { return UICollectionViewCell() }
//
//        cell.fill(index: indexPath.section, delegate: self)
//        return cell
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if velocity.x > 0 {
//            didScrolledTo.onNext(.right)
//        } else if velocity.x < 0 {
//            didScrolledTo.onNext(.left)
//        }
//    }
//}

extension TodoMainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension TodoMainViewController {
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}
