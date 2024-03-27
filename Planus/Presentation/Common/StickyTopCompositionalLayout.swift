//
//  StickyTopCompositionalLayout.swift
//  Planus
//
//  Created by Sangmin Lee on 3/24/24.
//

import UIKit

class StickyTopCompositionalLayout: UICollectionViewCompositionalLayout {
    
    var headerHeight: CGFloat = 330
    
    convenience init(headerHeight: CGFloat, sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) {
        self.init(sectionProvider: sectionProvider)
        self.headerHeight = headerHeight
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        guard let offset = collectionView?.contentOffset, let stLayoutAttributes = layoutAttributes else {
            return layoutAttributes
        }
        
        if offset.y < 0 {
            for attributes in stLayoutAttributes
            where attributes.representedElementKind == UICollectionView.elementKindSectionHeader
            && attributes.indexPath.section == 0 {
                let width = collectionView!.frame.width
                let height = headerHeight - offset.y
                attributes.frame = CGRect(x: 0, y: offset.y, width: width, height: height)
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
