//
//  MyGroupDetailLoadingCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/22.
//

import UIKit

final class MyGroupDetailLoadingCell: UICollectionViewCell {
    static let reuseIdentifier = "my-group-detail-loading-cell"
    
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        spinner.stopAnimating()
    }
    
    func configureView() {
        self.addSubview(spinner)
    }
    
    func configureLayout() {
        spinner.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
    }
    
    func start() {
        spinner.startAnimating()
    }
}
