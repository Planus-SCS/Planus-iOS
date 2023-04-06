//
//  MyGroupMemberEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import RxSwift

class MyGroupMemberEditViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: MyGroupMemberEditViewModel?
    
    var didTappedResignButton = PublishSubject<String>()
    
    lazy var memberCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createMemberSection())
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        cv.register(MyGroupMemberEditCell.self, forCellWithReuseIdentifier: MyGroupMemberEditCell.reuseIdentifier)
        cv.dataSource = self
        return cv
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: MyGroupMemberEditViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
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
        
        bind()
        
        navigationItem.setLeftBarButton(backButton, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = "그룹 멤버 관리"
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = MyGroupMemberEditViewModel.Input(
            didTappedResignButton: didTappedResignButton
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didRequestResign
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                // 요청됬다고 표시
            })
            .disposed(by: bag)
        
        output
            .didResignedAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.memberCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(memberCollectionView)
    }
    
    func configureLayout() {
        memberCollectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    @objc func backBtnAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func createMemberSection() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(66))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 26, bottom: 0, trailing: 26)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension MyGroupMemberEditViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.memberList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel?.memberList?[indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyGroupMemberEditCell.reuseIdentifier, for: indexPath) as? MyGroupMemberEditCell else { return UICollectionViewCell() }
        
        cell.fill(name: item.name, introduce: item.desc, isCaptin: item.isCap)
        cell.fill(image: UIImage(named: "DefaultProfileMedium")!)
        cell.fill { [weak self] in
            self?.didTappedResignButton.onNext(item.name)
        }
        return cell
    }
    
    
}
