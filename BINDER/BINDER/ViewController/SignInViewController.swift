//
//  ViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func SignUpBtnClicked(_ sender: Any) {
        guard let id = self.emailTextField.text else {
            return
        }
        guard let pw = self.pwTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: id, password: pw) {(authResut, error) in
            print(error?.localizedDescription)
            
            guard let user = authResut?.user else {
                return
            }
            
            print(user)
            
            let vcName = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
            vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(vcName!, animated: true, completion: nil)
        }
    }
    
    @IBAction func GoToSignInBtnClicked(_ sender: Any) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(vcName!, animated: true, completion: nil)
    }
}



