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
    
    func toAPM() -> String? {
        let components = self.components(separatedBy: ":")
        guard components.count == 2 else { return nil }
        let strHour = components[0]
        let strMinute = components[1]
        guard var hour = Int(strHour) else { return nil }
        var apm: String
        if hour > 12 {
            apm = "오후"
            hour = hour - 12
        } else {
            apm = "오전"
        }
        
        return "\(apm) \(hour):\(strMinute)"
    }
}
