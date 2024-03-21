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
    @IBOutlet private weak var generalButton: UIButton!
    @IBOutlet private weak var pointButton: UIButton!
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
        generalButton.safeTap
            .sink { [weak self] in
                self?.dismiss(animated: false) {
                    self?.viewModel.action(.cancelButtonTapped)
                }
            }
            .store(in: &cancellables)
        
        pointButton.safeTap
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
                self?.generalButton.isHidden = !state
            }
            .store(in: &cancellables)
        
        viewModel.$pointTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.pointButton.setTitle(title, for: .normal)
                self?.pointButton.titleLabel?.font = .omyu(size: 18)
            }
            .store(in: &cancellables)
        
        viewModel.$generalTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.generalButton.setTitle(title, for: .normal)
                self?.generalButton.titleLabel?.font = .omyu(size: 18)
            }
            .store(in: &cancellables)
    }
}
