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
    
    // 과목이름
    @IBOutlet weak var title: UILabel!
    // 답변 완료 여부 배경
    @IBOutlet weak var background: UIView!
    // 질문 내용
    @IBOutlet weak var questionContent: UILabel!
    // 답변 완료 여부
    @IBOutlet weak var answerCheck: UILabel!
    
    // 전체 셀 배경
    @IBOutlet weak var contentViewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
