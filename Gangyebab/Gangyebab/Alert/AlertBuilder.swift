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
        pointAction: CustomAlertAction
    ) {
        alertViewController.configure(CustomAlertViewModel(
            message: message,
            pointAction: pointAction
        ))
    }
    
    init(
        message: String,
        pointAction: CustomAlertAction,
        generalAction: CustomAlertAction?
    ) {
        alertViewController.configure(CustomAlertViewModel(
            message: message,
            pointAction: pointAction,
            generalAction: generalAction
        ))
    }

    
    func show(_ viewController: UIViewController) {
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.modalTransitionStyle = .crossDissolve
        viewController.present(alertViewController, animated: true)
    }
}
