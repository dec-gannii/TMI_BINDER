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
        backgroundColor = .gray1
        setTitleColor(.gray4, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// 클릭했을 때가 Highlight
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .skyBlue : isSelected ? .skyBlue : .gray1
            setTitleColor(isHighlighted ? .blue : isSelected ? .blue : .gray4, for: .normal)
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .skyBlue : .gray1
            setTitleColor(isSelected ? .blue : .gray4, for: .normal)
        }
    }
    
}
