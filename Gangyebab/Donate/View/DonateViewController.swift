//
//  DonateViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/22/24.
//

import UIKit
import Combine
import StoreKit

final class DonateViewController: UIViewController {

    @IBOutlet private weak var donate3000Button: UIButton!
    @IBOutlet private weak var donate5000Button: UIButton!
    @IBOutlet private weak var donate10000button: UIButton!
    @IBOutlet private weak var donte15000button: UIButton!
    @IBOutlet private var donateButtons: [UIButton]!
    @IBOutlet private weak var dismissButton: UIButton!
    private var viewModel: DonateViewModel?
    private var cancellables = Set<AnyCancellable>()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
        viewModel = DonateViewModel(viewController: self)
    }
}

extension DonateViewController {
    private func bindView() {
        dismissButton.safeTap
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        donateButtons.forEach { button in
            let id = "\(button.tag)"
            button.safeTap
                .sink { [weak self] _ in
                    self?.viewModel?.action(.buy(id))
                }
                .store(in: &cancellables)
        }
    }
}

extension DonateViewController: IAPDelegate {
    func showResult(_ result: Bool) {
        if result {
            AlertBuilder(
                message: "후원해 주셔서 감사합니다.\n오늘도 좋은 하루 되시길 바랍니다!.",
                pointAction: CustomAlertAction(
                    text: "확인",
                    action: {}
                )
            )
            .show(self)
        } else {
            AlertBuilder(
                message: "구매 중 오류가 발생했습니다.",
                pointAction: CustomAlertAction(
                    text: "확인",
                    action: {}
                )
            )
            .show(self)
        }
    }
}
