//
//  StudentEvaluationCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit

class StudentEvaluationCell: UITableViewCell {

    @IBOutlet weak var classColorView: UIView!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var monthPickerView: UIPickerView!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    @IBOutlet weak var showMoreInfoButton: UIButton!
    
    @IBAction func ShowMoreInfoBtnClicked(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.clipsToBounds = true
        cellBackgroundView.layer.cornerRadius = 20
        
        showMoreInfoButton.clipsToBounds = true
        showMoreInfoButton.layer.cornerRadius = 8
        
        self.selectionStyle = .none
    }
}
