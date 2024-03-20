//
//  RepeatRuleModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/17/24.
//

import Foundation

struct RepeatRuleModel {
    let repeatId: Int
    var title: String
    var importance: Importance
    var repeatType: RepeatType
    var date: String
    var isDeleted = false
}
