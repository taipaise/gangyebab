//
//  TodoCollectionViewCell.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

final class TodoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var importanceColor: UIView!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        importanceColor.isHidden = false
        contentLabel.attributedText = nil
    }
}

extension TodoCollectionViewCell {
    func configure(_ cellModel: TodoModel) {
        contentLabel.text = cellModel.title
        
        switch cellModel.importance {
        case .none:
            importanceColor.backgroundColor = .background1
        case .low:
            importanceColor.backgroundColor = .importanceLow
        case .medium:
            importanceColor.backgroundColor = .importanceMedium
        case .high:
            importanceColor.backgroundColor = .importanceHigh
        }
        
        if cellModel.isCompleted {
            importanceColor.isHidden = true
            contentLabel.attributedText = cellModel.title.strikeThrough()
            contentLabel.textColor = .stringColor2
        } else {
            contentLabel.text = cellModel.title
            contentLabel.textColor = .stringColor1
        }
    }
}
