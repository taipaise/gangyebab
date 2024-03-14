//
//  CustomAlertViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/14/24.
//

import Foundation
import Combine

struct CustomAlertAction {
    var text: String?
    var action: (() -> Void)?
}

final class CustomAlertViewModel {
    enum Input {
        case confirmButtonTapped
    }
    
    @Published private(set) var isCancelNeeded = false
    private(set) var message = CurrentValueSubject<String, Never>("")
    private var confirmAction: CustomAlertAction?
    
    init() {}
    
    init(
        message: String,
        confirmAction: CustomAlertAction,
        isCancelNeeded: Bool
    ) {
        self.message.send(message)
        self.confirmAction = confirmAction
        self.isCancelNeeded = isCancelNeeded
    }
    
    func action(_ input: Input) {
        switch input {
        case .confirmButtonTapped:
            confirm()
        }
    }
}

// MARK: - Action
extension CustomAlertViewModel {
    private func confirm() {
        guard let confirmAction = confirmAction else { return }
        confirmAction.action!()
    }
}

// MARK: - Method
extension CustomAlertViewModel {
    func configureConfirmAction(_ action: CustomAlertAction) {
        confirmAction = action
    }
}
