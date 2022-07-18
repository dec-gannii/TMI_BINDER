//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit
import Firebase

public class AddStudentVC: BaseVC {
    
    @IBOutlet weak var emailTf: UITextField!
    
    weak var delegate: AddStudentDelegate?
    var myClassDB = MyClassDBFunctions()
    var functionShare = FunctionShare()
    
    public override func updateViewConstraints() {
        let TOP_CARD_DISTANCE: CGFloat = 40.0
        
        var height: CGFloat = 0.0
        for v in self.view.subviews {
            height = height + 500
        }
        // change size of Viewcontroller's view to that height
        self.view.frame.size.height = height
        // reposition the view (if not it will be near the top)
        self.view.frame.origin.y = UIScreen.main.bounds.height - height - TOP_CARD_DISTANCE
        // apply corner radius only to top corners
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 30.0)
        super.updateViewConstraints()
    }
        
        // MARK: - 라이프 사이클
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame.size.height = 200
        
        var textfields = [UITextField]()
        textfields = [self.emailTf]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        /// 키보드 띄우기
        emailTf.becomeFirstResponder()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let resultVC = segue.destination as? ClassInfoVC, let item = sender as? StudentItem {
            resultVC.studentItem = item
            resultVC.delegate = delegate
        }
    }
    
    /// 계속하기 버튼 클릭
    /// - Parameter sender: 버튼
    @IBAction func onNext(_ sender: UIButton) {
        /// nil 처리
        guard let email = emailTf.text, !email.isEmpty else {
            showDefaultAlert(msg: "이메일을 입력해주세요.")
            return
        }
        myClassDB.SearchStudent(self: self, email: email)
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
