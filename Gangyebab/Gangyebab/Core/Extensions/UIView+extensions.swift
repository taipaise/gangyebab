//
//  UIView+extensions.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

public extension UIView {
    
    class var nib: UINib {
        return .init(nibName: self.className, bundle: self.bundle)
    }
    
    func loadNib() {
        let bundle = type(of: self).bundle
        loadNib(in: bundle)
    }
    
    func loadNib(in bundle: Bundle) {
        let nibName = type(of: self).className
        
        guard let nibs = bundle.loadNibNamed(nibName, owner: self, options: nil) else { return }
        guard let nib = nibs.first as? UIView else { return }
        
        nib.frame = bounds
        nib.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(nib)
    }
}
