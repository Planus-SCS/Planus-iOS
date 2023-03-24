//
//  MonthlyCollectionViewDataSource.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit

class SizeCache {
    
    static let shared = SizeCache()
    private init() {}
    
    var dict = [Int: CGFloat]() //갯수, 크기를 저장하자!
}

class MonthlyCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dayViewModelList = [DayViewModel]()
    
    var width: CGFloat = UIScreen.main.bounds.size.width
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayViewModelList.count
    }
    
    public func maxHeightIndex(index: Int) -> Int { //인덱스를 가져와야 되는거 아닌가?
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
        
        //            let mockCell = CustomCell(frame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * width, height: 300))
        // 이거를 스택뷰 바텀 늘리는걸 바꿔서 생성하는 뫀뷰 생성 메서드를 만들자!!!
        let maxIndex = maxHeightIndex(index: indexPath.item)
        var todoCount = dayViewModelList[maxIndex].todoList?.count ?? 0
        if let height = SizeCache.shared.dict[todoCount] {
            return CGSize(width: Double(1)/Double(7) * width, height: height)
        } else {
        
        var height = 20+todoCount*16 + (todoCount-1) * 2 + 2
        if height < 116 {
            height = 116
        }
        //            let maxTodoDayViewModel = dayViewModelList[maxIndex]
        //            mockCell.fill(day: "\(Calendar.current.component(.day, from: maxTodoDayViewModel.date))", state: maxTodoDayViewModel.state, weekDay: WeekDay(rawValue: Calendar.current.component(.weekday, from: maxTodoDayViewModel.date) - 1)!, todoList: maxTodoDayViewModel.todo)
        //            print("before:", mockCell.stackView.frame.height)
        //            mockCell.layoutIfNeeded()
        //            print("after:", mockCell.stackView.frame.height)
        //            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(width: Double(1)/Double(7) * width, height: 300))
        //            SizeCache.shared.dict[maxTodoDayViewModel.todo.count] = estimatedSize.height
        //            print(estimatedSize, width)
        
        // greaterthanorequaltto
        
        return CGSize(width: Double(1)/Double(7) * width, height: CGFloat(height))
        }
    }
}
