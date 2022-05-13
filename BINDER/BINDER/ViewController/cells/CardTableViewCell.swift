//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit

class CardTableViewCell: UITableViewCell {

    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var recentDate: UILabel!
    @IBOutlet weak var subjectGoal: UILabel!
    @IBOutlet weak var cntLb: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var manageBtn: UIButton!
    
    
    // 둥글게하기
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
