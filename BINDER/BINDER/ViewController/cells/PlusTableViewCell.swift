//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit

class PlusTableViewCell: UITableViewCell {

    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var plusImage: UIImageView!
    
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
