//
//  TodoCollectionViewCell.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

protocol TodoCellDelegate: AnyObject {
    func check(_ cellModel: TodoModel)
}

final class TodoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var importanceColor: UIView!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var selectButtonView: UIView!
    @IBOutlet private weak var selectImageView: UIImageView!
    @IBOutlet private weak var selectButton: UIButton!
    private var cellModel: TodoModel?
    weak var delegate: TodoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        importanceColor.isHidden = false
        contentLabel.attributedText = nil
    }
    
    @IBAction private func checkButtonTapped(_ sender: Any) {
        guard
            let cellModel = cellModel,
            let delegate = delegate
        else { return }
        
        delegate.check(cellModel)
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
