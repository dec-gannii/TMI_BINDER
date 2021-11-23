//
//  ViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var nameAlertLabel: UILabel!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var pwAlertLabel: UILabel!
    
    static var number : Int = 0
    var verified : Bool = false
    var type : String = ""
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        nameAlertLabel.isHidden = true
        pwAlertLabel.isHidden = true
        emailAlertLabel.isHidden = true
    }
    
    func saveInfo(_ number: Int, _ name: String, _ email: String, _ password: String, _ type: String){
        self.ref.child("users").child("user").child("\(SignInViewController.number)").setValue(["number":SignInViewController.number, "name":self.nameTextField.text, "email":self.emailTextField.text, "password":self.pwTextField.text, "type":self.type])
    }
    
    func isValidName(_ name: String) -> Bool {
        let nameValidation = name.trimmingCharacters(in: .whitespaces)
        if ((nameValidation.isEmpty) == true) {
            return false
        } else { return true }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    
    @IBAction func GoToSignInBtnClicked(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
        loginVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        loginVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(loginVC!, animated: true, completion: nil)
    }
    
    @IBAction func SignUpBtnClicked(_ sender: Any) {
        guard let name = self.nameTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        guard let id = self.emailTextField.text else { return }
        guard let pw = self.pwTextField.text else { return }
        
        self.emailAlertLabel.isHidden = true
        self.pwAlertLabel.isHidden = true
        self.nameAlertLabel.isHidden = true
        
        var verified = false
        
        if (self.isValidName(name) && self.isValidEmail(id) && self.isValidPassword(pw)) {
            Auth.auth().createUser(withEmail: id, password: pw) {(authResult, error) in
                print(error?.localizedDescription)
                Auth.auth().currentUser?.sendEmailVerification(completion: {(error) in
                    print("sended to " + id)
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        
                    }
                })
                self.saveInfo(SignInViewController.number, name, id, pw, self.type)
                SignInViewController.number = SignInViewController.number + 1
                guard let user = authResult?.user else {
                    return
                }
            }
            
            guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                //아니면 종료
                return
            }
            homeVC.number = SignInViewController.number
            homeVC.type = self.type
            homeVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            homeVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            //화면전환
            self.present(homeVC, animated: true)
            
        } else {
            if (!self.isValidEmail(id)){
                emailAlertLabel.isHidden = false
                emailAlertLabel.text = "이메일 형식이 올바르지 않습니다!"
            }
            if (!self.isValidPassword(pw)) {
                pwAlertLabel.isHidden = false
                pwAlertLabel.text = "비밀번호 형식이 올바르지 않습니다!"
            }
            if (!self.isValidName(name)) {
                nameAlertLabel.isHidden = false
                nameAlertLabel.text = "이름 형식이 올바르지 않습니다!"
            }
        }
    }
}




