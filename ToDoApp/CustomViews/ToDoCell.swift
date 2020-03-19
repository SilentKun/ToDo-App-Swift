//
//  ToDoCell.swift
//  ToDoApp
//
//  Created by imac4 on 20/02/2020.
//  Copyright © 2020 imac4. All rights reserved.
//

import Foundation
import UIKit

class ToDoCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var descLabelBottomConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(task: Task) {
        titleLabel.text = task.taskName
        descriptionLabel.text = task.description
        accessoryType = task.isCompleted ? .checkmark : .none
        if task.description?.isEmpty ?? false {
            descLabelBottomConstraint.constant = 0
        }
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        descriptionLabel.text = nil
        isHidden = false
    }
    
    override func awakeFromNib() {
        titleLabel.textColor = .blue
    }
}
