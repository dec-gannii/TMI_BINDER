//
//  PlusPortfolioCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/22.
//

import UIKit

class PlusPortfolioCell: UITableViewCell {

    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var plusContentViewBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentViewCell.clipsToBounds = true
        contentViewCell.layer.cornerRadius = 10
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
