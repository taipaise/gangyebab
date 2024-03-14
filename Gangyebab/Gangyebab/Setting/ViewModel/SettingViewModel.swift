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
    }
    
    @Published private(set) var currentAppVersion = ""
    
    init() {
        currentAppVersion = getCurrentAppVersion()
    }
    
    func action(_ input: Input) {
    }
}

// MARK: - Action
extension SettingViewModel {
    
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
