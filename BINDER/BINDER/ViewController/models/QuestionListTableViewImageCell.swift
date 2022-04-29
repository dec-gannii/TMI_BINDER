//
//  QuestionListTableViewCell.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import UIKit

class QuestionListTableViewImageCell: UITableViewCell {
    
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var title: UILabel!              // 질문 제목
    @IBOutlet weak var answerCheck: UILabel!        // 답변 완료 여부
    @IBOutlet weak var background: UIView!          // 답변 완료 여부 배경
    @IBOutlet weak var questionContent: UILabel!    // 질문 내용
    @IBOutlet weak var questionImage: UIImageView!  // 질문 이미지
    
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
    }
    
    
}
