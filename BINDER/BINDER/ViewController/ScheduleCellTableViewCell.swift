//
//  ScheduleCellTableViewCell.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/04.
//

import UIKit

class ScheduleCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scheduleDate: UILabel!
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var scheduleMemo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
