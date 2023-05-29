//
//  EmptyResultView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit

class EmptyResultView: UIView {
    let logoImageView: UIImageView = {
        let image = UIImage(named: "EmptyResultLogo")
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    convenience init(text: String) {
        self.init(frame: .zero)
        label.text = text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(logoImageView)
        self.addSubview(label)
    }
    
    func configureLayout() {
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }
    }
}
