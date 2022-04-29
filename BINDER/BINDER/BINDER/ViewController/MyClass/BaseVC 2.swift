//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit

class BaseVC: UIViewController{
    
    /// 알림 띄우는 함수
    func showDefaultAlert(msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let message = UIAlertAction(title: "확인", style: .default, handler: { action in
        })
        alert.addAction(message)
        self.present(alert, animated: true, completion: {
        })
    }
    
}

