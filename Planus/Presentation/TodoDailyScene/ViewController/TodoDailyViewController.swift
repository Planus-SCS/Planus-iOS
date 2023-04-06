//
//  TodoDailyViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

class TodoDailyViewController: UIViewController {
    
    var viewModel: TodoDailyViewModel?
    
    lazy var dateTitleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setImage(UIImage(named: "downButton"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(dateTitleBtnTapped), for: .touchUpInside)
        button.sizeToFit()
        return button
    }()
    
    lazy var addTodoButton: UIButton = {
        let image = UIImage(named: "plusBtn") ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(addTodoTapped), for: .touchUpInside)
        return button
    }()
    
    let collectionView: TodoDailyCollectionView = {
        let cv = TodoDailyCollectionView(frame: .zero)
//        cv.dataSource = self
//        cv.delegate = self
        return cv
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind() {
        
    }
    
    func configureView() {
        self.view.addSubview(dateTitleButton)
        self.view.addSubview(addTodoButton)
        self.view.addSubview(collectionView)
    }
    
    func configureLayout() {
        dateTitleButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.centerX.equalToSuperview()
        }
        
        addTodoButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(dateTitleButton)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(dateTitleButton.snp.bottom).offset(14)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    

    @objc func addTodoTapped(_ sender: UIButton) {
        
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

extension TodoDailyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let index,
              let item = delegate?.todoDailyCalendarCell(self, itemAt: index) else { return 0 }
        switch section {
        case 0:
            return item.scheduledTodoList.count
        case 1:
            return item.unSchedultedTodoList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigTodoCell.reuseIdentifier, for: indexPath) as? BigTodoCell else { return UICollectionViewCell() }
        
        var todoItem: Todo
        switch indexPath.section {
        case 0:
            todoItem = dayItem.scheduledTodoList[indexPath.item]
        case 1:
            todoItem = dayItem.unSchedultedTodoList[indexPath.item]
        default:
            return UICollectionViewCell()
        }
        cell.fill(title: todoItem.title, time: nil, category: todoItem.category)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: TodoDailyCollectionView.headerKind, withReuseIdentifier: TodoSectionHeaderSupplementaryView.reuseIdentifier, for: indexPath) as? TodoSectionHeaderSupplementaryView else { return UICollectionReusableView() }
        
        var title: String
        switch indexPath.section {
        case 0:
            title = "일정"
        case 1:
            title = "투두"
        default:
            fatalError()
        }
        headerview.fill(title: title)
     
        return headerview
    }
}