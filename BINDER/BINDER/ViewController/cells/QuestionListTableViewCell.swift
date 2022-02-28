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
        
        contentViewCell.clipsToBounds = true
        contentViewCell.layer.cornerRadius = 20
        
        background.clipsToBounds = true
        background.layer.cornerRadius = 8
        
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
