//
//  MonthPickerViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/27.
//

import UIKit
import RxSwift

class MonthPickerController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var year: Int?
    var month: Int?
    
    var currentYear: Int?
    var currentMonth: Int?
    
    var monthData: [String] = {
        (1...12).map { "\($0)월" }
    }()
    
    var bag = DisposeBag()
        
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.register(MonthPickerCell.self, forCellWithReuseIdentifier: MonthPickerCell.reuseIdentifier)
        
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        return collectionView
    }()
    
    var yearLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x000000)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        return label
    }()
    
    lazy var prevButton: UIButton = {
        let image = UIImage(named: "monthPickerLeft")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let image = UIImage(named: "monthPickerRight")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        return button
    }()
    
    convenience init(year: Int, month: Int) {
        self.init(nibName: nil, bundle: nil)
        self.year = year
        self.month = month
        
        self.currentYear = year
        self.currentMonth = month
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
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        print(self.view.frame.width)
        self.view.addSubview(yearLabel)
        self.view.addSubview(prevButton)
        self.view.addSubview(nextButton)
        self.view.addSubview(collectionView)
        yearLabel.text = "\(year ?? 0)년"
    }
    
    func configureLayout() {
        yearLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(30)
            $0.centerX.equalToSuperview()
        }
        
        prevButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.centerY.equalTo(yearLabel.snp.centerY)
        }
        
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(yearLabel.snp.centerY)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(yearLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(CGPoint(x: 290, y: 0), animated: false)
        }
    }
    
    @objc func prevTapped(_ sender: UIButton) {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x-290, y: 0), animated: true)
    }

    @objc func nextTapped(_ sender: UIButton) {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x+290, y: 0) , animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthPickerCell.reuseIdentifier, for: indexPath) as? MonthPickerCell else {
            return UICollectionViewCell()
        }

        cell.fill(
            month: monthData[indexPath.item],
            isCurrent: (year! + indexPath.section - 1 == currentYear) && (indexPath.item+1 == currentMonth)
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthData.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let doubleOffset = Double(scrollView.contentOffset.x)/Double(290)
        
        if doubleOffset < 1 && ceil(doubleOffset) == 0 {
            scrollView.setContentOffset(CGPoint(x: 290, y: 0), animated: false) //이때 앞으로 전진한거임. year를 하나 앞으로 바꾸고 리로드해야함
            year?-=1
            yearLabel.text = "\(year ?? 0)년"
            collectionView.reloadData()
        } else if doubleOffset > 1 && floor(doubleOffset) == 2 {
            scrollView.setContentOffset(CGPoint(x: 290, y: 0), animated: false)
            year?+=1
            yearLabel.text = "\(year ?? 0)년"
            collectionView.reloadData()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            DispatchQueue.main.async {
                self.prevButton.isUserInteractionEnabled = false
                self.nextButton.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.prevButton.isUserInteractionEnabled = true
            self.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .absolute(34)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(50)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    
    
}
