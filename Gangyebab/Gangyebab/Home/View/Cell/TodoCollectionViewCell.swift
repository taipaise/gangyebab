//
//  TodoCollectionViewCell.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

struct TodoCellModel: Hashable, Comparable {
    var uuid = UUID()
    let title: String
    let importance: Importance
    var isCompleted: Bool = false
    var repeatType: RepeatType
    var isEditing: Bool = false
    var isChecked: Bool = false
    
    static func < (lhs: TodoCellModel, rhs: TodoCellModel) -> Bool {
        return lhs.importance.rawValue > rhs.importance.rawValue
    }
}

final class TodoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var underLine: UIView!
    @IBOutlet private weak var importanceColor: UIView!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var checkImage: UIImageView!
    
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
        contentLabel.text = cellModel.title
        
        if cellModel.isEditing {
            checkImage.isHidden = false
        } else {
            checkImage.isHidden = true
        }
        
        if cellModel.isChecked {
            checkImage.image = UIImage(systemName: "circle.inset.filled")
        } else {
            checkImage.image = UIImage(systemName: "circle")
        }
        
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
            underLine.backgroundColor = .stringColor2
        } else {
            contentLabel.text = cellModel.title
            contentLabel.textColor = .stringColor1
            underLine.backgroundColor = .stringColor1
        }
    }
}
