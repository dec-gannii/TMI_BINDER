//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import Foundation
import UIKit

class CircleButton: UIButton {
    
    /// 기본 형태
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.init(rgb: 0xF5F5F5)
        setTitleColor(UIColor.init(rgb: 0x545357), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// 클릭했을 때가 Highlight
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.init(rgb: 0xCDE7FC) : isSelected ? UIColor.init(rgb: 0xCDE7FC) : UIColor.init(rgb: 0xF5F5F5)
            setTitleColor(isHighlighted ? UIColor.init(rgb: 0x0168FF) : isSelected ? UIColor.init(rgb: 0x0168FF) : UIColor.init(rgb: 0x545357), for: .normal)
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.init(rgb: 0xCDE7FC) : UIColor.init(rgb: 0xF5F5F5)
            setTitleColor(isSelected ? UIColor.init(rgb: 0x0168FF) : UIColor.init(rgb: 0x545357), for: .normal)
        }
    }

    
    
}
