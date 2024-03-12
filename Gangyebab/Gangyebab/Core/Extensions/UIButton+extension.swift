//
//  UIButton+extension.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import Combine
import CombineCocoa
import UIKit

public extension UIButton {
    
    var safeTap: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .touchUpInside)
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: false)
            .eraseToAnyPublisher()
    }
    
    func setUnderline(textColor: UIColor) {
        guard let title = titleLabel?.text else { return }
        
        let range = NSRange(location: 0, length: title.count)
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: range
        )
        attributedString.addAttribute(.foregroundColor, value: textColor, range: range)
        attributedString.addAttribute(.underlineColor, value: textColor, range: range)
        
        setAttributedTitle(attributedString, for: .normal)
    }
}
