//
//  HomeSegmentedControl.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit
import Combine

protocol HomeSegmentedControlDelegate: AnyObject {
    func segmentChanged()
}

final class HomeSegmentedControl: UIView {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var dayButton: UIButton!
    @IBOutlet private weak var monthButton: UIButton!
    @IBOutlet private weak var currentIndexView: UIView!
    
    private var currentIndex: Int = 0
    weak var delegate: HomeSegmentedControlDelegate?
    private var cancellables: Set<AnyCancellable> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
        setUI()
        bindView()
    }
    
    private func setUI() {
        [
            currentIndexView,
            stackView,
            dayButton,
            monthButton
        ].forEach { view in
            view?.layer.cornerRadius = 18
            view?.layer.masksToBounds = true
        }
        
        layer.cornerRadius = 18
        layer.masksToBounds = true
    }
    
}

// MARK: - Binding
extension HomeSegmentedControl {
    func bindView() {
        [dayButton, monthButton].forEach { button in
            button?.safeTap
                .sink { [weak self] in
                    guard let tag = button?.tag else { return }
                    self?.currentIndex = tag
                    self?.transformCurrentIndexView(to: button?.tag ?? 0)
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - segment 버튼 선택시 동작
extension HomeSegmentedControl {
    
    private func transformCurrentIndexView(to index: Int) {
        let buttonWidth = frame.width / 2
        UIView.animate(withDuration: 0.3) { [weak self] in
            if index == HomeType.month.rawValue {
                self?.currentIndexView.transform = CGAffineTransform(translationX: buttonWidth, y: 0)
            } else {
                self?.currentIndexView.transform = .identity
            }
            self?.updateTextColors()
        }
    }
    
    private func updateTextColors() {
        stackView.subviews.enumerated().forEach { index, view in
            let button: UIButton? = view as? UIButton
            if index == currentIndex {
                button?.tintColor = .gangyeWhite
            } else {
                button?.tintColor = .stringColor1
            }
        }
    }
}

enum HomeType: Int {
    case day
    case month
}
