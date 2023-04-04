//
//  JoinedGroupDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit
import RxSwift

enum JoinedGroupNoticeSectionKind: Int {
    case notice = 0
    case member
}

class JoinedGroupDetailViewController: UIViewController {
    static let headerElementKind = "joined-group-detail-view-controller-header-kind"

    lazy var outerScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = UIColor(hex: 0xF5F5FB)
        scrollView.delegate = self
        return scrollView
    }()
    
    var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xF5F5FB)
        return view
    }()
    
    lazy var horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = .systemBackground
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    
    // 이 안에 세개의 콜렉션뷰를 넣어야함.
    /*
     1. 공지사항, 멤버
     2. 캘린더 보기,
     3. 그룹 채팅
     */
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    var headerView = JoinedGroupDetailHeaderView(frame: .zero)
    var headerTabView = JoinedGroupDetailHeaderTabView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureView()
        configureLayout()
        
        testSetView()
    }
    
    func testSetView() {
        headerView.titleImageView.image = UIImage(named: "groupTest1")
        headerView.tagLabel.text = "#태그개수수수수 #네개까지지지지 #제한하는거다다 #어때아무글자텍스트테스트 #오개까지아무글자텍스"
        headerView.memberCountButton.setTitle("4/18", for: .normal)
        headerView.captinButton.setTitle("기정이짱짱", for: .normal)
        headerView.onlineButton.setTitle("4", for: .normal)
        
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
    }
    
    func configureView() {
        self.view.addSubview(outerScrollView)
        
        outerScrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(headerTabView)
        contentView.addSubview(horizontalScrollView)
        horizontalScrollView.addSubview(horizontalStackView)
    }
    
    func configureLayout() {
        
        outerScrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        headerView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(260)
        }
        
        headerTabView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(headerView)
            $0.height.equalTo(40)
        }
        horizontalScrollView.backgroundColor = .blue
        horizontalScrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.view.safeAreaLayoutGuide.snp.height).offset(-260)
            $0.bottom.equalToSuperview()
        }
        
        horizontalStackView.snp.makeConstraints {
            $0.edges.height.equalToSuperview()
        }
    }
    
    
}

extension JoinedGroupDetailViewController: UICollectionViewDelegate {
    
}
