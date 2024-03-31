//
//  MyGroupMemberCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import UIKit
import RxSwift

class MyGroupMemberCell: GroupIntroduceMemberCell {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        memberImageView.layer.borderWidth = 2
        memberImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(name: String, introduce: String?, isCaptin: Bool, isOnline: Bool, imgFetcher: Single<Data>) {
        super.fill(name: name, introduce: introduce, isCaptin: isCaptin, imgFetcher: imgFetcher)
        memberImageView.alpha = isOnline ? 1.0 : 0.5
        memberImageView.layer.borderColor
        = isOnline ? UIColor(hex: 0x6495F4).cgColor : UIColor.gray.cgColor

    }
}
