//
//  RepeatType.swift
//  Gangyebab
//
//  Created by 이동현 on 3/13/24.
//

import Foundation

enum RepeatType: Int, CaseIterable {
    case none
    case daily
    case weekly
    case monthly
    
    var description: String {
        switch self {
        case .none:
            "없음"
        case .daily:
            "매일"
        case .weekly:
            "매주"
        case .monthly:
            "매월"
        }
    }
}
