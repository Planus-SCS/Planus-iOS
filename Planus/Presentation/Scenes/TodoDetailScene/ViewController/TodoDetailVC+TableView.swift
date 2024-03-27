//
//  TodoDetailVC+TableView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/25.
//

import UIKit

extension TodoDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categorys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectCell.reuseIdentifier, for: indexPath) as? CategorySelectCell,
              let viewModel else { return UITableViewCell() }
        
        cell.nameLabel.text = viewModel.categorys[indexPath.row].title
        cell.colorView.backgroundColor = viewModel.categorys[indexPath.row].color.todoForCalendarColor
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            guard let viewModel = self.viewModel else { return }
            let item = viewModel.categorys[indexPath.row]
            guard let id = item.id else { return }
            
            self.categoryCreateView.nameField.text = item.title
            self.categoryCreateView.collectionView.selectItem(at: IndexPath(item: viewModel.categoryColorList.firstIndex(where: { $0 == item.color})!, section: 0), animated: false, scrollPosition: .top)
            
            self.didRequestEditCategoryAt.accept(id)
            success(true)
        }
        edit.backgroundColor = .systemTeal
        edit.image = UIImage(named: "edit_swipe")
        return UISwipeActionsConfiguration(actions:[edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .normal, title: "Remove") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            guard let categoryId = self.viewModel?.categorys[indexPath.row].id else { return }
            self.viewModel?.categorys.remove(at: indexPath.row)
            self.categoryView.tableView.deleteRows(at: [indexPath], with: .fade)
            self.didDeleteCategoryId.accept(categoryId)
            success(true)
        }
        remove.backgroundColor = .systemPink
        remove.image = UIImage(named: "remove_swipe")
        return UISwipeActionsConfiguration(actions:[remove])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectCategoryAt.accept(indexPath.row)
    }
}
