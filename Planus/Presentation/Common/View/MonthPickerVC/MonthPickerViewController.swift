//
//  MonthPickerViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/27.
//

import UIKit
import RxSwift

class MonthPickerViewController: UIViewController {
    
    var firstYear: Int?
    var firstMonth: Int?
    
    var centeredYear: Int?
    
    var currentYear: Int?
    var currentMonth: Int?
    
    var lastYear: Int?
    var lastMonth: Int?
    
    var completion: ((Date) -> Void)?
    
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
        collectionView.register(MonthPickerCell.self, forCellWithReuseIdentifier: MonthPickerCell.reuseIdentifier)
        
        collectionView.backgroundColor = .planusBackgroundColor
        return collectionView
    }()
    
    var yearLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .planusBlack
        label.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        return label
    }()
    
    lazy var prevButton: UIButton = {
        let image = UIImage(named: "pickerLeft")
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
        let image = UIImage(named: "pickerRight")
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
    
    convenience init(firstYear: Date, lastYear: Date, currentDate: Date, completion: @escaping (Date) -> Void) {
        self.init(nibName: nil, bundle: nil)
        let currentComponents = Calendar.current.dateComponents([.year, .month], from: currentDate)
        self.currentYear = currentComponents.year
        self.currentMonth = currentComponents.month
        self.centeredYear = currentComponents.year
        
        let firstComponents = Calendar.current.dateComponents([.year, .month], from: firstYear)
        self.firstYear = firstComponents.year
        self.firstMonth = firstComponents.month
        
        let lastComponents = Calendar.current.dateComponents([.year, .month], from: lastYear)
        self.lastYear = lastComponents.year
        self.lastMonth = lastComponents.month
        self.completion = completion
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(CGPoint(x: 290, y: 0), animated: false)
        }
    }
    
    func configureView() {
        self.view.backgroundColor = .planusBackgroundColor
        self.view.addSubview(yearLabel)
        self.view.addSubview(prevButton)
        self.view.addSubview(nextButton)
        self.view.addSubview(collectionView)
        yearLabel.text = "\(centeredYear ?? 0)년"
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
    }
    
    @objc func prevTapped(_ sender: UIButton) {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x-290, y: 0), animated: true)
    }

    @objc func nextTapped(_ sender: UIButton) {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x+290, y: 0) , animated: true)
    }
    
}
