//
//  EditInfoViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/09.
//

import UIKit
import Firebase

class EditInfoViewController: UIViewController {
    
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    
    var type = ""
    var currentPW = ""
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordCheck: UITextField!
    @IBOutlet weak var parentPassword: UITextField!
    @IBOutlet weak var parentPasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
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
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    
    func getInfo() {
        // 데이터베이스 경로
        var docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let userName = data?["Name"] as? String ?? ""
                self.nameTextField.text = userName
                let userEmail = data?["Email"] as? String ?? ""
                self.emailLabel.text = userEmail
                let parentPW = data?["parentPW"] as? String ?? ""
                self.parentPassword.text = parentPW
                //                self.userName = data?["Name"] as? String ?? ""
                //                self.userEmail = data?["Email"] as? String ?? ""
                //                self.parentPW = data?["parentPW"] as? String ?? ""
                self.type = data?["Type"] as? String ?? ""
                self.currentPW = data?["Password"] as? String ?? ""
            } else {
                docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid)
                
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let userName = data?["Name"] as? String ?? ""
                        self.nameTextField.text = userName
                        let userEmail = data?["Email"] as? String ?? ""
                        self.emailLabel.text = userEmail
                        self.type = data?["Type"] as? String ?? ""
                        self.currentPW = data?["Password"] as? String ?? ""
                        self.parentPassword.isHidden = true
                        self.parentPasswordLabel.isHidden = true
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    // 선생님 정보 저장하는 메소드
    func saveInfo(_ name: String, _ password: String, _ parentPW: String){
        let db = Firestore.firestore()
        
        // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
        db.collection("\(self.type)").document(Auth.auth().currentUser!.uid).updateData([
            "Name": name,
            "Password": password,
            "parentPW": parentPW
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    // 학생 정보 저장하는 메소드
    func saveStudentInfo(_ name: String, _ password: String){
        let db = Firestore.firestore()
        
        // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
        db.collection("\(self.type)").document(Auth.auth().currentUser!.uid).updateData([
            "Name": name,
            "Password": password
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    @IBAction func CancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func CheckPW() -> Bool {
        let newPW = self.newPassword.text
        let newPWCheck = self.newPasswordCheck.text
        if ((newPW == "" && newPWCheck == "") || (newPW == self.currentPW && newPWCheck == self.currentPW)) {
            return true
        }
        if (newPW == newPWCheck) {
            if (self.isValidPassword(newPW!)) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func CheckParentPW() -> Bool {
        let parentPW = self.parentPassword.text
        if (self.type == "teacher"){
            if (parentPassword.text!.count <= 6) {
                if let convertedNum = Int(parentPW!) {
                    print("\(convertedNum)")
                    return true
                } else {
                    return false
                }
            }
        } else {
            return true
        }
        return true
    }
    
    func CheckName() -> Bool {
        let userName = self.nameTextField.text
        if (isValidName(userName!)) {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func OKBtnClicked(_ sender: Any) {
        var name = self.nameTextField.text ?? ""
        var newPW = self.currentPW
        var parentPW = self.parentPassword.text ?? ""
        
        if (self.CheckPW() && self.CheckName() && self.CheckParentPW()) {
            newPW = self.newPassword.text!
            name = self.nameTextField.text!
            parentPW = self.parentPassword.text!
            
            if ((newPassword.text == "" && newPasswordCheck.text == "") || (newPassword.text == self.currentPW && newPasswordCheck.text == self.currentPW)) {
                newPW = self.currentPW
            }
            
            if (newPW != self.currentPW) {
                if (self.type == "teacher") {
                    saveInfo(name, newPW, parentPW)
                } else if (self.type == "student") {
                    saveStudentInfo(name, newPW)
                }
                
                Auth.auth().currentUser?.updatePassword(to: newPW) { error in
                    print("error")
                }
                
                guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
                
                loginVC.modalPresentationStyle = .fullScreen
                loginVC.modalTransitionStyle = .crossDissolve
                loginVC.isLogouted = true
                
                self.present(loginVC, animated: true, completion: nil)
            } else {
                if (name != "") {
                    saveInfo(name, newPW, parentPW)
                    
                    guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                        //아니면 종료
                        return
                    }
                    
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
                    tb.selectedIndex = 3
                    self.present(tb, animated: true, completion: nil)
                }
            }
        } else {
            if (!self.CheckPW()) {
                let alert = UIAlertController(title: "오류", message: "비밀번호가 올바르지 않습니다!", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) {
                    (action) in
                    self.newPassword.text = ""
                    self.newPasswordCheck.text = ""
                }
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
            } else if (!self.CheckName()) {
                let alert = UIAlertController(title: "오류", message: "이름이 올바르지 않습니다!", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) {
                    (action) in
                    self.nameTextField.text = ""
                }
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
            } else if (!self.CheckParentPW()) {
                let alert = UIAlertController(title: "오류", message: "학부모 비밀번호가 올바르지 않습니다!", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) {
                    (action) in
                    self.parentPassword.text = ""
                }
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
            } else if (!self.CheckParentPW() || !self.CheckName() || !self.CheckPW()) {
                let alert = UIAlertController(title: "오류", message: "다시 입력해주세요!", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) {
                    (action) in
                    self.nameTextField.text = ""
                    self.newPassword.text = ""
                    self.newPasswordCheck.text = ""
                    if (!self.parentPassword.isHidden) {
                        self.parentPassword.text = ""
                    }
                }
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
            }
        }
        
        
    }
}

