//
//  JoinedGroupDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit
import RxSwift

class JoinedGroupDetailViewController: UIViewController {
    
    var headerView = JoinedGroupDetailHeaderView(frame: .zero)
    
    
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
        self.view.addSubview(headerView)
    }
    
    func configureLayout() {
        headerView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(260)
        }
    }
    
    
}
