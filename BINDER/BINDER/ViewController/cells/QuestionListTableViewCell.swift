//
//  QuestionListViewCell.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import UIKit
import Kingfisher
import Firebase

class QuestionListTableViewCell: UITableViewCell {
    
    // 테이블 뷰 요소 연결
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var questionContent: UILabel!
    @IBOutlet weak var answerisCheck: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentViewCell.clipsToBounds = true
        contentViewCell.layer.cornerRadius = 20
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
