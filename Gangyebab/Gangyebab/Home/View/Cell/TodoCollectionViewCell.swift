//
//  TodoCollectionViewCell.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

struct TodoCellModel: Hashable, Comparable {
    let uuid = UUID()
    let content: String
    let importance: Importance
    var isCompleted: Bool = false
    
    static func < (lhs: TodoCellModel, rhs: TodoCellModel) -> Bool {
        return lhs.importance.rawValue > rhs.importance.rawValue
    }
}

final class TodoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var underLine: UIView!
    @IBOutlet private weak var importanceColor: UIView!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        importanceColor.isHidden = false
        contentLabel.attributedText = nil
    }
}

extension TodoCollectionViewCell {
    func configure(_ cellModel: TodoCellModel) {
        contentLabel.text = cellModel.content
        
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
            contentLabel.attributedText = cellModel.content.strikeThrough()
            contentLabel.textColor = .stringColor2
            underLine.backgroundColor = .stringColor2
        } else {
            contentLabel.text = cellModel.content
            contentLabel.textColor = .stringColor1
            underLine.backgroundColor = .stringColor1
        }
    }
}
