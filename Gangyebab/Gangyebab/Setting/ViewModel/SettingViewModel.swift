//
//  SettingViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/14/24.
//

import Foundation
import Combine

final class SettingViewModel: ViewModel {
    enum Input {
        case toggle(_ state: Bool)
    }
    
    @Published private(set) var currentAppVersion = ""
    @Published private(set) var switchState = false
    private let userdefaultManager = UserDefaultManager.shared
    
    init() {
        currentAppVersion = getCurrentAppVersion()
        
        let state = userdefaultManager.getSwitchState()
        switchState = state
    }
    
    func action(_ input: Input) {
        switch input {
        case .toggle(let state):
            toggle(state)
        }
    }
}

// MARK: - Action
extension SettingViewModel {
    private func toggle(_ state: Bool) {
        switchState = state
        userdefaultManager.saveSwitchState(state)
    }
}

extension SettingViewModel {
    private func getCurrentAppVersion() -> String {
        guard
            let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String
        else { return "" }
        return version
    }
}
