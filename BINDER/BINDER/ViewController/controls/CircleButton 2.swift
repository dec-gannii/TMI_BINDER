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
        backgroundColor = UIColor.init(rgb: 0xB1B6C0)
        setTitleColor(UIColor.init(rgb: 0x13203E), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircle()
    }
    
    /// 클릭했을 때가 Highlight
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.init(rgb: 0x101B34) : isSelected ? UIColor.init(rgb: 0x101B34) : UIColor.init(rgb: 0xB1B6C0)
            setTitleColor(isHighlighted ? UIColor.white : isSelected ? UIColor.white : UIColor.init(rgb: 0x13203E), for: .normal)
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.init(rgb: 0x101B34) : UIColor.init(rgb: 0xB1B6C0)
            setTitleColor(isSelected ? UIColor.white : UIColor.init(rgb: 0x13203E), for: .normal)
        }
    }

    
    
}
