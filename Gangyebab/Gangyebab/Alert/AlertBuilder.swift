//
//  AlertBuilder.swift
//  Gangyebab
//
//  Created by 이동현 on 3/14/24.
//

import UIKit

final class AlertBuilder {
    private let alertViewController = CustomAlertViewController()
        
    init(
        message: String,
        confirmAction: CustomAlertAction,
        isCancelNeeded: Bool
    ) {
        alertViewController.configure(CustomAlertViewModel(
            message: message,
            confirmAction: confirmAction,
            isCancelNeeded: isCancelNeeded
        ))
    }
    
    func show(_ viewController: UIViewController) {
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.modalTransitionStyle = .crossDissolve
        viewController.present(alertViewController, animated: true)
    }
}
