//
//  EmailVerificationViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/15.
//

import UIKit
import Firebase
import FirebaseAuth

public class EmailVerificationViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailVerificationAlertLabel: UILabel!
    
    var email: String = ""
    var type: String = ""
    var functionShare = FunctionShare()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var textfields = [UITextField]()
        textfields = [self.emailTF]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        self.emailVerificationAlertLabel.isHidden = true
        self.emailTF.text = email
        self.emailTF.isEnabled = false
    }
    
    @IBAction func OKBtnClicked(_ sender: Any) {
        verifyCheck()
    }
    
    func verifyCheck() {
        self.emailVerificationAlertLabel.isHidden = true
        
        Auth.auth().currentUser?.reload()
        let check = Auth.auth().currentUser?.isEmailVerified
        
        if (check == true) {
            self.emailVerificationAlertLabel.isHidden = true
            guard let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfoController") as? StudentSubInfoController else { return }
            subInfoVC.modalPresentationStyle = .fullScreen
            subInfoVC.modalTransitionStyle = .crossDissolve
            subInfoVC.type = self.type
            self.present(subInfoVC, animated: true, completion: nil)
        } else {
            self.emailVerificationAlertLabel.text = "인증 확인이 완료되지 않았습니다."
            self.emailVerificationAlertLabel.isHidden = false
        }
    }
    
}
