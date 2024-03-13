//
//  AddTodoViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/13/24.
//

import UIKit
import Combine

final class AddTodoViewController: UIViewController {

    @IBOutlet private weak var dismissButton1: UIButton!
    @IBOutlet private weak var dismissButton2: UIButton!
    @IBOutlet private weak var todoTextField: UITextField!
    @IBOutlet private weak var noneButton: UIButton!
    @IBOutlet private weak var lowButton: UIButton!
    @IBOutlet private weak var mediumButton: UIButton!
    @IBOutlet private weak var highButton: UIButton!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
    }
}

// MARK: - UI Configuration
extension AddTodoViewController {
    private func setUI() {
        todoTextField.font = .soyo(size: 15, weight: .regular)
    }
}

// MARK: - binding
extension AddTodoViewController {
    private func bindView() {
        [dismissButton1, dismissButton2].forEach { button in
            button?.safeTap
                .sink(receiveValue: { [weak self] in
                    self?.dismiss(animated: false)
                })
                .store(in: &cancellables)
        }
        
        [
            noneButton,
            lowButton,
            mediumButton,
            highButton
        ].forEach { button in
            button?.safeTap
                .sink(receiveValue: { [weak self] in
                    //ViewModel로 중요도 설정
                })
                .store(in: &cancellables)
        }
    }
}

// MARK: - Method
extension AddTodoViewController {
    private func transformCurrentIndexView(type: Importance) {
        
    }
}
