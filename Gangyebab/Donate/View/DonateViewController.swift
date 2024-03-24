//
//  DonateViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/22/24.
//

import UIKit
import Combine

final class DonateViewController: UIViewController {

    @IBOutlet private weak var donate3000Button: UIButton!
    @IBOutlet private weak var donate5000Button: UIButton!
    @IBOutlet private weak var donate10000button: UIButton!
    @IBOutlet private weak var donte15000button: UIButton!
    @IBOutlet private weak var dismissButton: UIButton!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
    }
}

extension DonateViewController {
    private func bindView() {
        dismissButton.safeTap
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}
