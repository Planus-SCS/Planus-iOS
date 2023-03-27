//
//  TodoDailyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit

class TodoDailyCalendarCell: UICollectionViewCell {
    
    weak var delegate: TodoDailyCalendarCellDelegate?
    
    var index: Int?
    var collectionView = TodoDailyCollectionView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func fill(index: Int, delegate: TodoDailyCalendarCellDelegate) {
        self.index = index
        self.delegate = delegate
    }
    
}

extension TodoDailyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let item = delegate?.todoDailyCalendarCell(self, itemAt: section) else { return 0 }
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
        guard let index,
              let dayItem = delegate?.todoDailyCalendarCell(self, itemAt: index),
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigTodoCell.reuseIdentifier, for: indexPath) as? BigTodoCell else { return UICollectionViewCell() }
        
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
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
}

protocol TodoDailyCalendarCellDelegate: NSObject {
    func todoDailyCalendarCell(_ todoDailyCalendarCell: TodoDailyCalendarCell, itemAt: Int) -> DetailDayViewModel
}
