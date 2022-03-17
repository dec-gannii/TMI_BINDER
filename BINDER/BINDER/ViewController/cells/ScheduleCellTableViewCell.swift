//
//  ScheduleCellTableViewCell.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/04.
//

import UIKit

// 일정 리스트 테이블 뷰 셀
class ScheduleCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scheduleDate: UILabel!
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var scheduleMemo: UILabel!
    @IBOutlet weak var scheduleBackgroundView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scheduleBackgroundView.clipsToBounds = true
        scheduleBackgroundView.layer.cornerRadius = 15
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
