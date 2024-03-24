//
//  LicenseDetailViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/23/24.
//

import UIKit
import Combine

final class LicenseDetailViewController: UIViewController {

    @IBOutlet private weak var licenseNameLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var dismissButton: UIButton!
    private var viewModel = LicenseDetailViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        bindView()
        setUI()
    }
    
    private func setUI() {
        textView.layer.cornerRadius = 10
        textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func configure(_ license: License) {
        viewModel.configure(license)
    }
}

extension LicenseDetailViewController {
    private func bindViewModel() {
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.licenseNameLabel.text = title
            }
            .store(in: &cancellables)
        
        viewModel.$detail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                self?.textView.text = detail
            }
            .store(in: &cancellables)
    }
    
    private func bindView() {
        dismissButton.safeTap
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}
