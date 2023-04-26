//
//  String+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
