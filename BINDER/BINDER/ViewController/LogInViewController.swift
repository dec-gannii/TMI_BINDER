//
//  LogInViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/21.
//

import UIKit
import Firebase
import GoogleSignIn

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var googleLogInBtn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    @IBAction func LogInBtnClicked(_ sender: Any) {
        guard let email = emailTextField.text, let password = pwTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as? NSError {
                print("error : \n")
                print(error)
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                    let alert = UIAlertController(title: "로그인 실패", message: "존재하지 않는 계정입니다.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                case .userDisabled:
                    // Error: The user account has been disabled by an administrator.
                    let alert = UIAlertController(title: "로그인 실패", message: "사용할 수 없는 사용자 계정입니다.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                case .wrongPassword:
                    // Error: The password is invalid or the user does not have a password.
                    let alert = UIAlertController(title: "로그인 실패", message: "비밀번호가 올바르지 않습니다.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                case .invalidEmail:
                    // Error: Indicates the email address is malformed.
                    let alert = UIAlertController(title: "로그인 실패", message: "유효하지 않은 이메일입니다.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                default:
                    let alert = UIAlertController(title: "로그인 실패", message: "로그인에 실패하였습니다. 다시 시도해주세요.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                }
            } else {
                print("User signs in successfully")
                let vcName = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
                vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(vcName!, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func SignInBtnClicked(_ sender: Any) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(vcName!, animated: true, completion: nil)
    }
    
}



