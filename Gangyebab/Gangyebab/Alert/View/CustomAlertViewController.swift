//
//  CustomAlertViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/14/24.
//

import UIKit
import Combine

final class CustomAlertViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var confirmButton: UIButton!
    private var viewModel = CustomAlertViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
        bindViewModel()

    }
    
    func configure(_ viewModel: CustomAlertViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Binding
extension CustomAlertViewController {
    private func bindView() {
        cancelButton.safeTap
            .sink { [weak self] in
                self?.dismiss(animated: false)
            }
            .store(in: &cancellables)
        
        confirmButton.safeTap
            .sink { [weak self] in
                self?.dismiss(animated: false) {
                    self?.viewModel.action(.confirmButtonTapped)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        viewModel.message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.messageLabel.text = message
            }
            .store(in: &cancellables)
        
        viewModel.$isCancelNeeded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.cancelButton.isHidden = !state
            }
            .store(in: &cancellables)
    }
}
