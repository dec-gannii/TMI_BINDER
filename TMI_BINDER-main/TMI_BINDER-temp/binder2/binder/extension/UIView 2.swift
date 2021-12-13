//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import Foundation
import UIKit


extension UIView {
    
    /// 라운드 처리
    func makeCircle() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true
    }
    
    /// 상단 라운드 처리
    func topRound() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    /// 전체 라운드 처리
    func allRound() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
    }
    
}
