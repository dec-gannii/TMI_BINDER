//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit

class CardTableViewCell: UITableViewCell {

    @IBOutlet weak var classColor: UIView!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var subjectGoal: UILabel!
    @IBOutlet weak var recentDate: UILabel!
    @IBOutlet weak var cntLb: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var manageBtn: UIButton!
    
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
