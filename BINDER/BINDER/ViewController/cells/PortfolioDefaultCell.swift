//
//  PortfolioDefaultCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/22.
//

import UIKit

class PortfolioDefaultCell: UITableViewCell {

    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var ContentViewBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        content.clipsToBounds = true
        content.layer.cornerRadius = 10
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        content.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
