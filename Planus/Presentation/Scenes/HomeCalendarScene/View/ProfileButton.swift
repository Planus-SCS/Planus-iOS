//
//  ProfileButton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import UIKit

final class ProfileButton: UIButton {
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.contentMode = .scaleAspectFill
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
        profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
    }
    
    private func configureView() {
        self.addSubview(profileImageView)
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.height.width.equalTo(30)
            $0.center.equalToSuperview()
        }
    }
    
    func fill(with data: Data?) {
        self.profileImageView.image = (data != nil) ? UIImage(data: data!) : UIImage(named: "DefaultProfileSmall")
    }
}
