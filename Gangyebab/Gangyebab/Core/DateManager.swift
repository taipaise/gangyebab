//
//  DateManager.swift
//  Gangyebab
//
//  Created by 이동현 on 3/17/24.
//

import Foundation

final class DateManager {
    static let shared = DateManager()
    private var dateFormatter = DateFormatter()
    
    private init() {
        dateFormatter.locale = Locale(identifier: "ko_KR")
    }
    
    func dateToString(_ date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func stringToDate(_ string: String) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: string) ?? Date()
    }
    
    func dateToStringForHome(_ date: Date) -> String {
        dateFormatter.dateFormat = "yy.MM.dd (E)"
        return dateFormatter.string(from: date)
    }
}
