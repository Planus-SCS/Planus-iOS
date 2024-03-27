//
//  TodoDetailVC+CollectionView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/25.
//

import UIKit

extension TodoDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.categoryColorList.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCreateCell.reuseIdentifier, for: indexPath) as? CategoryCreateCell,
              let item = viewModel?.categoryColorList[indexPath.item] else { return UICollectionViewCell() }
        cell.fill(color: item.todoLeadingColor)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel?.categoryColorList[indexPath.item] else { return }
        didChangednewCategoryColor.accept(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didChangednewCategoryColor.accept(nil)
    }
}
