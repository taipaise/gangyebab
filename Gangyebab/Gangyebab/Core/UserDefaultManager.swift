//
//  UserDefaultManager.swift
//  Gangyebab
//
//  Created by 이동현 on 3/23/24.
//

import Foundation

final class UserDefaultManager {
    static let shared = UserDefaultManager()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    private func setDate() {
        let dateString = DateManager.shared.dateToString(Date())
        userDefaults.set(dateString, forKey: "DATE")
    }
    
    private func getDate() -> String? {
        return userDefaults.string(forKey: "DATE")
    }
    
    func getSwitchState() -> Bool {
        return userDefaults.bool(forKey: "SWITCH")
    }
    
    func saveSwitchState(_ isOn: Bool) {
        userDefaults.set(isOn, forKey: "SWITCH")
    }
    
    func isFirstExecute() -> Bool {
        let todayString = DateManager.shared.dateToString(Date())

        guard
            let date = getDate(),
            date == todayString
        else {
            setDate()
            return true
        }
        return false
    }
}
