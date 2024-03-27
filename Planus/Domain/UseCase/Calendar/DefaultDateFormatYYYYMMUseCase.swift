//
//  DefaultDateFormatYYYYMMUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation

class DefaultDateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter
    }()
    
    func execute(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
