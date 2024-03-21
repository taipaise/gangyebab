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
        case cancelButtonTapped
    }
    
    @Published private(set) var isCancelNeeded = false
    @Published private(set) var pointTitle = ""
    @Published private(set) var generalTitle = ""
    private(set) var message = CurrentValueSubject<String, Never>("")
    private var pointAction: CustomAlertAction?
    private var generalAction: CustomAlertAction?
    
    init() {}
    
    init(
        message: String,
        pointAction: CustomAlertAction
    ) {
        self.message.send(message)
        self.pointAction = pointAction
        self.isCancelNeeded = false
        
        if let title = pointAction.text { pointTitle = title }
    }
    
    init(
        message: String,
        pointAction: CustomAlertAction,
        generalAction: CustomAlertAction?
    ) {
        self.message.send(message)
        self.pointAction = pointAction
        self.generalAction = generalAction
        self.isCancelNeeded = true
        
        if let pointTitle = pointAction.text { self.pointTitle = pointTitle }
        if let generalTitle = generalAction?.text { self.generalTitle = generalTitle }
    }
    
    
    func action(_ input: Input) {
        switch input {
        case .confirmButtonTapped:
            confirm()
        case .cancelButtonTapped:
            cancel()
        }
    }
}

// MARK: - Action
extension CustomAlertViewModel {
    private func confirm() {
        guard let confirmAction = pointAction else { return }
        confirmAction.action!()
    }
    private func cancel() {
        guard 
            let generalAction = generalAction,
            let action = generalAction.action
        else { return }
        action()
    }
}

// MARK: - Method
extension CustomAlertViewModel {
    func configureConfirmAction(_ action: CustomAlertAction) {
        pointAction = action
    }
    
    func configureCancelAction(_ action: CustomAlertAction) {
        generalAction = action
    }
}
