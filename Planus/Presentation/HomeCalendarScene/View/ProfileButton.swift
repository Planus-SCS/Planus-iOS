//
//  ProfileButton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import UIKit

class ProfileButton: UIButton {
    let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = self.bounds.height/2
        profileImageView.layer.cornerCurve = .continuous
    }
    
    func configureView() {
        self.addSubview(profileImageView)
    }
    
    func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.height.width.equalTo(self.snp.height)
            $0.center.equalToSuperview()
        }
    }
    
    func fill(with image: UIImage?) {
        self.profileImageView.image = (image != nil) ? image : UIImage(named: "userDefaultIconSmall")
    }
}
