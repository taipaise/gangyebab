//
//  Importance.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

enum Importance: Int {
    case none
    case low
    case medium
    case high
    
    var color: UIColor {
        switch self {
        case .none:
            return .white
        case .low:
            return .importanceLow
        case .medium:
            return .importanceMedium
        case .high:
            return .importanceHigh
        }
    }
}
