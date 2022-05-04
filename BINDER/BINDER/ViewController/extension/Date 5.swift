//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import Foundation
import UIKit


extension Date {
    
    /// 포맷처리
    func formatted() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "YYYY-MM-dd HH:mm"
        return formatter_time.string(from: self)
    }
    
}
