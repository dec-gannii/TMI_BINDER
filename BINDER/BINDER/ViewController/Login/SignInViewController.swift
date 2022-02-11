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
class SignInViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    //    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameAlertLabel: UILabel!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var pwAlertLabel: UILabel!
    //    @IBOutlet weak var ageAlertLabel: UILabel!
    
    static var number : Int = 1
    var verified : Bool = false
    var type : String = ""
    var ref: DatabaseReference!
    var isGoogleSignIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // 오류 발생 시 나타날 label들 우선 숨겨두기
        nameAlertLabel.isHidden = true
        pwAlertLabel.isHidden = true
        emailAlertLabel.isHidden = true
        
        if (isGoogleSignIn == true) {
            emailTextField.text = Auth.auth().currentUser?.email
            nameTextField.text = Auth.auth().currentUser?.displayName
            pwTextField.placeholder = "이메일로 전송된 링크에서 변경한 비밀번호를 입력해주세요."
            Auth.auth().sendPasswordReset(withEmail: (Auth.auth().currentUser?.email)!)
            emailTextField.isEnabled = false
        } 
    }
    
    // 정보 저장하는 메소드
    func saveInfo(_ number: Int, _ name: String, _ email: String, _ password: String, _ type: String){
        let db = Firestore.firestore()
        
        // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
        db.collection("\(type)").document(Auth.auth().currentUser!.uid).setData([
            "Name": name,
            "Email": email,
            "Password": password,
            "Type": type,
            "Uid": Auth.auth().currentUser?.uid,
            "Profile": Auth.auth().currentUser?.photoURL?.absoluteString
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    // 유효한 이름인지 (공백은 아닌지) 검사하는 메소드
    func isValidName(_ name: String) -> Bool {
        let nameValidation = name.trimmingCharacters(in: .whitespaces)
        if ((nameValidation.isEmpty) == true) {
            return false
        } else { return true }
    }
    
    // 이메일 형식인지 검사하는 메소드
    func isValidEmail(_ email: String) -> Bool {
        if (self.isGoogleSignIn == true) { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
            tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
            tb.tabBar.tintColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
            self.present(tb, animated: true, completion: nil)
            self.present(homeVC, animated: true, completion: nil)
            
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
            loginVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            loginVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(loginVC!, animated: true, completion: nil)
        }
    }
    
    // 회원가입 버튼 클릭 시 실행되는 메소드
    @IBAction func SignUpBtnClicked(_ sender: Any) {
        // textfield들의 값 가져와서 로컬 변수에 저장
        guard let name = self.nameTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        guard let id = self.emailTextField.text else { return }
        guard let pw = self.pwTextField.text else { return }
        //        guard let age = Int(self.ageTextField.text!.trimmingCharacters(in: .whitespaces)) else { return }
        
        self.emailAlertLabel.isHidden = true
        self.pwAlertLabel.isHidden = true
        self.nameAlertLabel.isHidden = true
        //        self.ageAlertLabel.isHidden = true
        
        // 이름, 이메일, 비밀번호, 나이가 모두 유효하다면, && self.isValidAge(age)
        
        if (self.isValidName(name) && self.isValidEmail(id) && self.isValidPassword(pw) ) {
            // 사용자를 생성
            Auth.auth().createUser(withEmail: id, password: pw) {(authResult, error) in
                print(error?.localizedDescription)
                Auth.auth().currentUser?.sendEmailVerification(completion: {(error) in
                    print("sended to " + id)
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        
                    }
                })
                
                // 정보 저장 , age
                self.saveInfo(SignInViewController.number, name, id, pw, self.type)
                SignInViewController.number = SignInViewController.number + 1
                guard let user = authResult?.user else {
                    return
                }
            }
            
            // 타입이 학생이라면,
            if(type == "student" || type == "teacher"){
                // 추가 정보를 입력하는 뷰로 이동
                //                let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfo")
                guard let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfoController") as? StudentSubInfoController else {
                    //아니면 종료
                    return
                }
                subInfoVC.type = self.type
                subInfoVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                subInfoVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(subInfoVC, animated: true, completion: nil)
            } else{
                // 아니라면 바로 홈으로 이동
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
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
                tb.tabBar.tintColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
                self.present(tb, animated: true, completion: nil)
            }
        } else {
            if (isGoogleSignIn == false) {
                // 유효하지 않다면, 에러가 난 부분 label로 알려주기 위해 error label 숨김 해제
                if (!self.isValidEmail(id)){
                    emailAlertLabel.isHidden = false
                    emailAlertLabel.text = "이메일 형식이 올바르지 않습니다!"
                }
                if (!self.isValidPassword(pw)) {
                    pwAlertLabel.isHidden = false
                    pwAlertLabel.text = "비밀번호 형식이 올바르지 않습니다!"
                }
            } else {
                // 정보 저장 , age
                self.saveInfo(SignInViewController.number, name, id, pw, self.type)
                SignInViewController.number = SignInViewController.number + 1
                
                // 추가 정보를 입력하는 뷰로 이동
                //                let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfo")
                guard let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfoController") as? StudentSubInfoController else {
                    //아니면 종료
                    return
                }
                subInfoVC.type = self.type
                subInfoVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                subInfoVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(subInfoVC, animated: true, completion: nil)
            }
            if (!self.isValidName(name)) {
                nameAlertLabel.isHidden = false
                nameAlertLabel.text = "이름 형식이 올바르지 않습니다!"
            }
        }
    }
}




