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
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
    }
    
    private func dateToString(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    private func stringToDate(_ string: String) -> Date {
        return dateFormatter.date(from: string) ?? Date()
    }
}
