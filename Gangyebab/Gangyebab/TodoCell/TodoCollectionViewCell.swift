//
//  TodoCollectionViewCell.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

final class TodoCollectionViewCell: UICollectionViewCell {
    enum IsChecked {
        case checked
        case unchecked
        
        var image: UIImage {
            switch self {
            case .checked:
                return UIImage(systemName: "circle.inset.filled")!
            case .unchecked:
                return UIImage(systemName: "circle")!
            }
        }
    }
    
    @IBOutlet private weak var importanceColor: UIView!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var selectButtonView: UIView!
    @IBOutlet private weak var selectImageView: UIImageView!
    private var cellModel: TodoModel?
    private var isChecked: IsChecked = .unchecked
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        importanceColor.isHidden = false
        contentLabel.attributedText = nil
        selectImageView.isHidden = true
    }
}

extension TodoCollectionViewCell {
    func configure(_ cellModel: TodoModel, isCheckNeed: Bool = false) {
        self.cellModel = cellModel
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
        
        selectButtonView.isHidden = !isCheckNeed
    }
}

// MARK: - check 시 동작
extension TodoCollectionViewCell {
    
    func toggleCheck() {
        switch isChecked {
        case .checked:
            isChecked = .unchecked
        case .unchecked:
            isChecked = .checked
        }
        
        selectImageView.image = isChecked.image
    }
}
