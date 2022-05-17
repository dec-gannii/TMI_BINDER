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

// 회원가입 뷰 컨트롤러
public class SignInViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var nameAlertLabel: UILabel!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var pwAlertLabel: UILabel!
    
    static var number : Int = 1
    var verified : Bool = false
    var type : String = ""
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    var isGoogleSignIn : Bool = false
    var isAppleSignIn : Bool = false
    
    var name: String = ""
    var email: String = ""
    var viewDesign = ViewDesign()
    var functionShare = FunctionShare()
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        /// 키보드 올라올 때 화면 쉽게 이동할 수 있도록 해주는 것, 키보드 높이만큼 padding
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        var textfields = [UITextField]()
        textfields = [self.nameTextField, self.emailTextField, self.pwTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        /// 키보드 띄우기
        self.nameTextField.becomeFirstResponder()
        
        // 오류 발생 시 나타날 label들 우선 숨겨두기
        nameAlertLabel.isHidden = true
        pwAlertLabel.isHidden = true
        emailAlertLabel.isHidden = true
        
        if (isGoogleSignIn == true || isAppleSignIn == true) {
            emailTextField.text = Auth.auth().currentUser?.email
            nameTextField.text = Auth.auth().currentUser?.displayName
            pwTextField.placeholder = "이메일로 전송된 링크에서 변경한 비밀번호를 입력해주세요."
            Auth.auth().sendPasswordReset(withEmail: (Auth.auth().currentUser?.email)!)
            emailTextField.isEnabled = false
        } else {
        }
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 키보드 올라올때 처리
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillShow(notification:NSNotification) {
        if (self.emailTextField.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.emailTextField.frame.height + 20)
        }
    }
    
    /// 키보드 내려갈때 처리
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.frame.origin.y = 0 // Move view 150 points upward
    }
    
    // 유효한 이름인지 (공백은 아닌지) 검사하는 메소드
    func isValidName(_ name: String) -> Bool {
        let nameValidation = name.trimmingCharacters(in: .whitespaces)
        if ((nameValidation.isEmpty) == true) {
            return false
        } else { return true }
    }
    
    // 유효한 비밀번호인지 검사하는 메소드
    func isValidPassword(_ password: String) -> Bool {
        // 최소한 6개의 문자로 이루어져 있어야 함
        if (self.isGoogleSignIn == true) { return false }
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    
    // 로그인 버튼 클릭 시 실행되는 메소드
    @IBAction func GoToSignInBtnClicked(_ sender: Any) {
        if (self.isGoogleSignIn == true) {
            guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                //아니면 종료
                return
            }
            // 데이터 넘겨주기
            homeVC.id = self.emailTextField.text!
            homeVC.pw = self.pwTextField.text!
            homeVC.number = SignInViewController.number
            homeVC.name = self.nameTextField.text!
            homeVC.type = self.type
            homeVC.verified = true
            
            guard let myClassVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                return
            }
            guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                return
            }
            
            guard let myPageVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                return
            }
            
            // tab bar 추가하기
            let tb = UITabBarController()
            tb.modalPresentationStyle = .fullScreen // 전체화면으로 보이게 설정
            tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
            tb.tabBar.tintColor = viewDesign.titleColor
            self.present(tb, animated: true, completion: nil)
            self.present(homeVC, animated: true, completion: nil)
        } else {
            DeleteUserWhileSignUp()
            // 로그인 화면(첫화면)으로 다시 이동
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    // 회원가입 버튼 클릭 시 실행되는 메소드
    @IBAction func SignUpBtnClicked(_ sender: Any) {
        // textfield들의 값 가져와서 로컬 변수에 저장
        guard let name = self.nameTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        guard let id = self.emailTextField.text else { return }
        guard let pw = self.pwTextField.text else { return }
        
        self.emailAlertLabel.isHidden = true
        self.pwAlertLabel.isHidden = true
        self.nameAlertLabel.isHidden = true
        
        switch self.type {
        case "teacher", "student", "parent":
            CreateUser(type: self.type, self: self, name: name, id: id, pw: pw)
            break
        default:
            break
        }
    }
}
