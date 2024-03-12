//
//  TodoHeaderSupplementaryView.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import UIKit

final class TodoHeaderSupplementaryView: UICollectionReusableView {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(_ type: TodoSection) {
        switch type {
        case .inProgress:
            imageView.image = .eggWhite
            titleLabel.text = "해야 할 일"
        case .completed:
            imageView.image = .eggBrown
            titleLabel.text = "완료한 일"
        }
    }
   
    
}
