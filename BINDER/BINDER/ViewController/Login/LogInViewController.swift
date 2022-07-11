//
//  LogInViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/21.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

/// log in view controller
public class LogInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var pwAlertLabel: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var loginButton: UIButton!
    
    // 변수 선언
    var isLogouted: Bool!
    var email:String!
    var name:String!
    
    var functionShare = FunctionShare()
    var loginDB = LogInVCDBFunctions()
    
    var disposeBag = DisposeBag()
    
    func _init(){
        isLogouted = true
        email = ""
        name = ""
    }
    
    private func checkId(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    private func checkPw(_ password: String) -> Bool {
        return password.count >= 6 && !password.isEmpty
    }
    
    private func bindUI() {
        
        let idInputOb = emailTextField.rx.text.orEmpty.asObservable()
        let idCheckOb = idInputOb.map(checkId)   // 아이디 유형체크
        let pwInputOb = pwTextField.rx.text.orEmpty.asObservable()
        let pwCheckOb = pwInputOb.map(checkPw)   // 비밀번호 유형체크
        
        self.emailAlertLabel.isHidden = true
        self.pwAlertLabel.isHidden = true
        
        idCheckOb.subscribe(onNext: { s in   // s: true or false
                if s {   //아이디 형식이 맞는경우
                    self.emailAlertLabel.isHidden = true
                } else {  //아이디 형식 아닌경우
                    self.emailAlertLabel.text = StringUtils.emailValidationAlert.rawValue
                    self.emailAlertLabel.textColor = .red
                    self.emailAlertLabel.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        pwCheckOb.subscribe(onNext: { s in   // s: true or false
                if s {   //아이디 형식이 맞는경우
                    self.pwAlertLabel.isHidden = true
                } else {  //아이디 형식 아닌경우
                    self.pwAlertLabel.text = StringUtils.wrongPassword.rawValue
                    self.pwAlertLabel.textColor = .red
                    self.pwAlertLabel.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            //아이디 유형을 체크한 값이 내려옴 true/false
            idCheckOb, pwCheckOb, resultSelector: {s1, s2 in s1 && s2}
            )
            .subscribe(onNext: {s in  // s1 && s2 결과값
                self.loginButton.isEnabled = s
                if s {
                    self.loginButton.backgroundColor = .skyBlue
                } else {
                    self.loginButton.backgroundColor = .white
                }
            })
            .disposed(by: disposeBag)
        }
    
    /// Load View
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 키보드 띄우기
        self.emailTextField.becomeFirstResponder()
        
        var textfields = [UITextField]()
        textfields = [self.emailTextField, self.pwTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        emailAlertLabel.isHidden = true
        pwAlertLabel.isHidden = true
        
        bindUI()
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
                self.loginDB.LogInAndShowHomeVC(email: email, password: password, self: self)
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
