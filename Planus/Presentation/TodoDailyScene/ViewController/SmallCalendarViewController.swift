//
//  SmallCalendarViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

final class SmallCalendarViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var viewModel: SmallCalendarViewModel?
    
    var didScrolledToIndex = PublishSubject<Double>()
    var didSelectItemAt = PublishSubject<IndexPath>()
    
    var smallCalendarView: SmallCalendarView?
    
    convenience init(viewModel: SmallCalendarViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let view = SmallCalendarView(frame: CGRect(x: 0, y: 0, width: 320, height: 400))
        self.view = view
        self.smallCalendarView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = SmallCalendarViewModel.Input(
            didLoadView: Observable.just(()),
            didSelectAt: didSelectItemAt.asObservable(),
            didChangedIndex: didScrolledToIndex.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didChangedTitleLabel
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, title in
                vc.smallCalendarView?.dateLabel.text = title
            })
            .disposed(by: bag)
        
        output
            .didLoadInitDays
            .compactMap { $0 }
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let frameWidth = vc.view.frame.width
                vc.reloadAndMove(to: CGPoint(x: frameWidth * CGFloat(count/2), y: 0))
            })
            .disposed(by: bag)
        
        output
            .didLoadPrevDays
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let exPointX = vc.smallCalendarView?.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
                let frameWidth = vc.view.frame.width
                vc.reloadAndMove(to: CGPoint(x: exPointX + CGFloat(count)*frameWidth, y: 0))
            })
            .disposed(by: bag)
        
        output
            .didLoadFollowingDays
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let exPointX = vc.smallCalendarView?.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
                let frameWidth = vc.view.frame.width
                vc.reloadAndMove(to: CGPoint(x: exPointX - CGFloat(count)*frameWidth, y: 0))
            })
            .disposed(by: bag)
        
        output
            .shouldDismiss
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: bag)
    }
    
    func reloadAndMove(to point: CGPoint) {
        smallCalendarView?.smallCalendarCollectionView.reloadData()
        smallCalendarView?.smallCalendarCollectionView.performBatchUpdates {
            smallCalendarView?.smallCalendarCollectionView.setContentOffset(
                point,
                animated: false
            )
        }
    }
    
    func configureView() {
        smallCalendarView?.smallCalendarCollectionView.dataSource = self
        smallCalendarView?.smallCalendarCollectionView.delegate = self
        
        smallCalendarView?.prevButton.addTarget(self, action: #selector(prevBtnTapped), for: .touchUpInside)
        smallCalendarView?.nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
}

// MARK: Target Actions

extension SmallCalendarViewController {
    @objc func prevBtnTapped(_ sender: UIButton) {
        let exPointX = smallCalendarView?.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        smallCalendarView?.smallCalendarCollectionView.setContentOffset(CGPoint(x: exPointX - frameWidth, y: 0), animated: true)
    }
    
    @objc func nextBtnTapped(_ sender: UIButton) {
        let exPointX = smallCalendarView?.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        smallCalendarView?.smallCalendarCollectionView.setContentOffset(CGPoint(x: exPointX + frameWidth, y: 0), animated: true)
    }
}

extension SmallCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.viewModel?.days.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel?.days[section].count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SmallCalendarDayCell.reuseIdentifier,
            for: indexPath
        ) as? SmallCalendarDayCell,
              let viewModel = self.viewModel,
              let minDate = viewModel.minDate,
              let maxDate = viewModel.maxDate,
              let currentDate = viewModel.currentDate else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.days[indexPath.section][indexPath.row]
        var isValid: Bool
        switch item.date {
        case (minDate...maxDate):
            isValid = true
        default:
            isValid = false
        }

        cell.fill(day: item.dayLabel, state: item.state, isSelectedDay: item.date == currentDate, isValid: isValid)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt.onNext(indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pointX = scrollView.contentOffset.x
        let frameWidth = smallCalendarView?.smallCalendarCollectionView.frame.width ?? CGFloat()
        
        let index = pointX/frameWidth
        self.didScrolledToIndex.onNext(index)
        if index.truncatingRemainder(dividingBy: 1.0) == 0 {
            DispatchQueue.main.async { [weak self] in
                self?.smallCalendarView?.prevButton.isUserInteractionEnabled = true
                self?.smallCalendarView?.nextButton.isUserInteractionEnabled = true
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.smallCalendarView?.prevButton.isUserInteractionEnabled = false
                self?.smallCalendarView?.nextButton.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            DispatchQueue.main.async { [weak self] in
                scrollView.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [weak self] in
            scrollView.isUserInteractionEnabled = true
        }
    }
}
