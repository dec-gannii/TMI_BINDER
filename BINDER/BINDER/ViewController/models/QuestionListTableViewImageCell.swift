//
//  QuestionListTableViewCell.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import UIKit

class QuestionListTableViewImageCell: UITableViewCell {
    
    @IBOutlet weak var contentViewCell: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var answerCheck: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var questionContent: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentViewCell.clipsToBounds = true
        contentViewCell.layer.cornerRadius = 20
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
