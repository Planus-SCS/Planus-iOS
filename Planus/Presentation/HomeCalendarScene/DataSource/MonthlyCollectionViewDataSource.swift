//
//  MonthlyCollectionViewDataSource.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit

class MonthlyCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dayViewModelList = [DayViewModel]()
    
    var sizeCache = [Int: CGFloat]()
    var width: CGFloat = UIScreen.main.bounds.size.width
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayViewModelList.count
    }
    
    public func maxHeightIndexInWeek(index: Int) -> Int { //인덱스를 가져와야 되는거 아닌가?
        return ((index-index%7)..<(index+7-index%7)).max(by: { (a,b) in
            dayViewModelList[a].todoList?.count ?? 0 < dayViewModelList[b].todoList?.count ?? 0
        }) ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell else {
            return UICollectionViewCell()
        }
        let dayViewModel = dayViewModelList[indexPath.item]
        
        cell.fill(day: "\(Calendar.current.component(.day, from: dayViewModel.date))", state: dayViewModel.state, weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!, todoList: dayViewModel.todoList)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dayViewModel = dayViewModelList[indexPath.item]
                
        let maxIndex = maxHeightIndexInWeek(index: indexPath.item)
        var todoCount = dayViewModelList[maxIndex].todoList?.count ?? 0
        
        if let height = sizeCache[todoCount] {
            return CGSize(width: Double(1)/Double(7) * width, height: height)
            
        } else {
            let maxTodoDayViewModel = dayViewModelList[maxIndex]
            
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * width, height: 116))
            mockCell.fill(todoList: maxTodoDayViewModel.todoList)

            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(width: Double(1)/Double(7) * width, height: 116))
            sizeCache[maxTodoDayViewModel.todoList?.count ?? Int()] = estimatedSize.height
            
            return CGSize(width: Double(1)/Double(7) * width, height: estimatedSize.height)
            
        }
    }
}
