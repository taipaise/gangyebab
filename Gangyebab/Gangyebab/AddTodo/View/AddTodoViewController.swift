//
//  AddTodoViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/13/24.
//

import UIKit
import Combine

protocol AddTodoDelegate: AnyObject {
    func transferTodo(_ todo: TodoModel)
}

final class AddTodoViewController: UIViewController {
    
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var todoTextField: UITextField!
    @IBOutlet private weak var noneButton: UIButton!
    @IBOutlet private weak var lowButton: UIButton!
    @IBOutlet private weak var mediumButton: UIButton!
    @IBOutlet private weak var highButton: UIButton!
    @IBOutlet private weak var importanceView: UIView!
    @IBOutlet private weak var importanceSelectView: UIView!
    @IBOutlet private var importanceLabels: [UILabel]!
    @IBOutlet private weak var repeatButton: UIButton!
    @IBOutlet private weak var repeatLabel: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    
    weak var delegate: AddTodoDelegate?
    private var viewModel = AddTodoViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindView()
        bindViewModel()
    }
    
    func configure(_ todo: TodoModel) {
        viewModel.configure(todo)
    }
}

// MARK: - UI Configuration
extension AddTodoViewController {
    private func setUI() {
        todoTextField.font = .soyo(size: 15, weight: .regular)
        todoTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        todoTextField.delegate = self
        
        var repeatActions: [UIAction] = []

        for type in RepeatType.allCases {
            let action = UIAction(
                title: type.description,
                image: nil,
                handler: { [weak self] _ in
                    self?.repeatLabel.text = type.description
                    self?.viewModel.action(.updateRepeatType(type))
                }
            )
            repeatActions.append(action)
            repeatButton.showsMenuAsPrimaryAction = true
        }

        repeatButton.menu = UIMenu(
            title: "",
            image: nil,
            identifier: nil,
            options: .displayInline,
            children: repeatActions
        )
    }
}

// MARK: - binding
extension AddTodoViewController {
    private func bindView() {
        dismissButton.safeTap
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: false)
            }
            .store(in: &cancellables)
        
        [
            noneButton,
            lowButton,
            mediumButton,
            highButton
        ]
            .forEach { button in
                guard let button = button else { return }
                button.safeTap
                    .sink(receiveValue: { [weak self] in
                        self?.viewModel.action(.updateImportance(button.tag))
                    })
                    .store(in: &cancellables)
            }
        
        completeButton.safeTap
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if viewModel.title.value.isEmpty {
                    AlertBuilder(
                        message: "할 일을 입력해 주세요.",
                        confirmAction: CustomAlertAction(text: "확인", action: {}),
                        isCancelNeeded: false
                    )
                    .show(self)
                } else {
                    self.delegate?.transferTodo(self.viewModel.getTodo())
                    self.dismiss(animated: false)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        viewModel.title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.todoTextField.text = title
            }
            .store(in: &cancellables)
        
        viewModel.importance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] importance in
                self?.transformCurrentIndexView(type: importance)
            }
            .store(in: &cancellables)
        
        viewModel.repeatType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] repeatType in
                self?.repeatLabel.text = repeatType.description
            }
            .store(in: &cancellables)
    }
}

// MARK: - Method
extension AddTodoViewController {
    private func transformCurrentIndexView(type: Importance) {
        let width = importanceView.frame.width / 4
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let transLationX = CGFloat(type.rawValue) * width
            self?.importanceSelectView.transform = CGAffineTransform(translationX: transLationX, y: 0)
               
            self?.importanceLabels.forEach { label in
                label.textColor = .stringColor1
            }
            self?.importanceLabels[type.rawValue].textColor = .gangyeWhite
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - textField Delegate
extension AddTodoViewController: UITextFieldDelegate {
    @objc func textFieldDidChange(_ sender: Any?) {
        guard let text = todoTextField.text else { return }
        viewModel.action(.updateTitle(text))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
