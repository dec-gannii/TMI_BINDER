//
//  LogInViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/21.
//

import UIKit
import Firebase

/// log in view controller
public class LogInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var pwAlertLabel: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    
    // 변수 선언
    var isLogouted: Bool!
    var email:String!
    var name:String!
    
    var functionShare = FunctionShare()
    
    func _init(){
        isLogouted = true
        email = ""
        name = ""
    }
    
    /// Load View
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if (isLogouted == false) {
        //            GIDSignIn.sharedInstance()?.restorePreviousSignIn() // 자동로그인
        //        }
        
        var textfields = [UITextField]()
        textfields = [self.emailTextField, self.pwTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        emailAlertLabel.isHidden = true
        pwAlertLabel.isHidden = true
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    /// log in button clicked
    @IBAction func LogInBtnClicked(_ sender: Any) {
        self.pwAlertLabel.isHidden = true
        self.emailAlertLabel.isHidden = true
        
        guard let email = emailTextField.text, let password = pwTextField.text else { return }
        
        // 로그인 수행 시, 에러 발생하면 띄울 alert
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as? NSError {
                switch AuthErrorCode(rawValue: error.code) {
                case .userDisabled:
                    let alert = UIAlertController(title: "로그인 실패", message: StringUtils.emailValidationAlert.rawValue, preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                case .wrongPassword:
                    self.emailAlertLabel.isHidden = true
                    self.pwAlertLabel.isHidden = false
                    self.pwAlertLabel.text = StringUtils.wrongPassword.rawValue
                    break
                case .emailAlreadyInUse:
                    Auth.auth().signIn(withEmail: email, password: password)
                    break
                default:
                    let alert = UIAlertController(title: "로그인 실패", message: StringUtils.loginFail.rawValue, preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                }
            } else {
                // 별 오류 없으면 로그인 되어서 홈 뷰 컨트롤러 띄우기
                LogInAndShowHomeVC(email: email, password: password, self: self)
            }
        }
    }
    
    /// reset password button clicked
    @IBAction func ResetPasswordBtnClicked(_ sender: Any) {
        guard let resetpwVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController else { return }
        resetpwVC.modalPresentationStyle = .pageSheet
        resetpwVC.modalTransitionStyle = .coverVertical
        self.present(resetpwVC, animated: true, completion: nil)
    }
}
