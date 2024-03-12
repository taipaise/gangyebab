//
//  UICollectionView+extension.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

extension UICollectionView {
    func register(cells: [UICollectionViewCell.Type], usingNib: Bool = true) {
        cells.forEach {
            if usingNib {
                register($0.nib, forCellWithReuseIdentifier: $0.className)
            } else {
                register($0, forCellWithReuseIdentifier: $0.className)
            }
        }
    }
}
