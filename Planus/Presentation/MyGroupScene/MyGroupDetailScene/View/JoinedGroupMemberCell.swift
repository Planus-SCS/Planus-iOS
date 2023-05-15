//
//  JoinedGroupMemberCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import UIKit

class JoinedGroupMemberCell: GroupIntroduceMemberCell {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        memberImageView.layer.borderWidth = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(name: String, introduce: String?, isCaptin: Bool, isOnline: Bool) {
        super.fill(name: name, introduce: introduce, isCaptin: isCaptin)
        memberImageView.alpha = isOnline ? 1.0 : 0.5
        memberImageView.layer.borderColor
        = isOnline ? UIColor(hex: 0x6495F4).cgColor : UIColor.gray.cgColor

    }
}
