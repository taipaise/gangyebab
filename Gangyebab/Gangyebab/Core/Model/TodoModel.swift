//
//  TodoModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/17/24.
//

import Foundation

struct TodoModel: Hashable, Comparable {
    var uuid = UUID()
    let title: String
    let importance: Importance
    var isCompleted: Bool = false
    var repeatType: RepeatType
    var date: String
    var repeatId: Int = -1
    
    static func < (lhs: TodoModel, rhs: TodoModel) -> Bool {
        if lhs.isCompleted != rhs.isCompleted {
            return !lhs.isCompleted
        }
        
        return lhs.importance.rawValue > rhs.importance.rawValue
    }
}
