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
    var functionShare = FunctionShare()
    // MARK: - 라이프 사이클
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
        SearchStudent(self: self, email: email)
    }
}

