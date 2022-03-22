//
//  EditInfoViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/09.
//
// 정보 수정 화면

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
//        getInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getInfo() // 사용자 정보 가져오기
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
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
    
    // 사용자 정보를 가져오는 메소드
    func getInfo() {
        // 데이터베이스 경로
        var docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // 이름, 이메일, 학부모 인증용 비밀번호, 사용자의 타입
                let userName = data?["name"] as? String ?? ""
                self.nameTextField.text = userName
                let userEmail = data?["email"] as? String ?? ""
                self.emailLabel.text = userEmail
                let parentPW = data?["parentPW"] as? String ?? ""
                self.parentPassword.text = parentPW
                self.type = data?["type"] as? String ?? ""
                self.currentPW = data?["password"] as? String ?? ""
            } else {
                // 현재 사용자에 해당하는 선생님 문서가 없으면 학생 문서로 다시 검색
                docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let userName = data?["name"] as? String ?? ""
                        self.nameTextField.text = userName
                        let userEmail = data?["email"] as? String ?? ""
                        self.emailLabel.text = userEmail
                        self.type = data?["type"] as? String ?? ""
                        self.currentPW = data?["password"] as? String ?? ""
                        self.parentPassword.isHidden = true
                        self.parentPasswordLabel.isHidden = true
                    } else {
                        docRef = self.db.collection("parent").document(Auth.auth().currentUser!.uid)
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let userName = data?["name"] as? String ?? ""
                                self.nameTextField.text = userName
                                let userEmail = data?["email"] as? String ?? ""
                                self.emailLabel.text = userEmail
                                self.type = data?["type"] as? String ?? ""
                                self.currentPW = data?["password"] as? String ?? ""
                                self.parentPasswordLabel.text = "자녀 휴대전화 번호"
                                let childPhoneNumber = data?["childPhoneNumber"] as? String ?? ""
                                self.parentPassword.text = childPhoneNumber
                            } else {
                                print("Document does not exist")
                            }
                        }
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
            "name": name,
            "password": password,
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
            "name": name,
            "password": password
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    // 학부모 정보 저장하는 메소드
    func saveParentInfo(_ name: String, _ password: String, _ childPhoneNumber: String){
        let db = Firestore.firestore()
        
        // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
        db.collection("\(self.type)").document(Auth.auth().currentUser!.uid).updateData([
            "name": name,
            "password": password,
            "childPhoneNumber": childPhoneNumber
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    // 뒤로가기 버튼 클릭 시 수행되는 메소드
    @IBAction func CancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 비밀번호 체크를 하는 메소드
    func CheckPW() -> Bool {
        let newPW = self.newPassword.text // 새롭게 변경할 비밀번호
        let newPWCheck = self.newPasswordCheck.text // 새롭게 변경할 비밀번호 확인
        if ((newPW == "" && newPWCheck == "") || (newPW == self.currentPW || newPWCheck == self.currentPW)) {
            // 새롭게 변경할 비밀번호와 새롭게 변경할 비밀번호 확인이 모두 공백이거나 현재의 비밀번호와 새로운 비밀번호가 동일한 경우
            return true
        }
        if (newPW == newPWCheck) { // 새롭게 변경할 비밀번호와 새롭게 변경할 비밀번호 확인이 동일하면,
            if (self.isValidPassword(newPW!)) { // 유효한 비밀번호인 경우
                return true
            } else { // 유효하지 않은 비밀번호인 경우
                return false
            }
        } else { // 새롭게 변경할 비밀번호와 새롭게 변경할 비밀번호 확인이 동일하지 않으면,
            return false
        }
    }
    
    // 학부모 인증용 비밀번호 확인 메소드
    func CheckParentPW() -> Bool {
        let parentPW = self.parentPassword.text
        if (self.type == "teacher"){
            if (parentPassword.text!.count <= 6) {
                if let convertedNum = Int(parentPW!) { // 숫자형으로 변환
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
    
    // 유효한 이름인지 확인하는 메소드
    func CheckName() -> Bool {
        let userName = self.nameTextField.text
        if (isValidName(userName!)) {
            return true
        } else {
            return false
        }
    }
    
    // 확인 버튼 클릭 시 수행되는 메소드
    @IBAction func OKBtnClicked(_ sender: Any) {
        var name = self.nameTextField.text ?? ""
        var newPW = self.currentPW
        var parentPW = self.parentPassword.text ?? ""
        
        if (self.CheckPW() && self.CheckName() && self.CheckParentPW()) { // 이름, 비밀번호, 학부모 비밀번호 확인이 모두 되면
            newPW = self.newPassword.text!
            name = self.nameTextField.text!
            parentPW = self.parentPassword.text!
            
            if ((newPassword.text == "" && newPasswordCheck.text == "") || (newPassword.text == self.currentPW || newPasswordCheck.text == self.currentPW)) {
                // 새롭게 변경할 비밀번호와 새롭게 변경할 비밀번호 확인이 모두 공백이거나 새로운 비밀번호가 현재 비밀번호와 동일하면 새로운 비밀번호를
                // 현재 비밀번호로 설정
                newPW = self.currentPW
            }
            // 만약 새로운 비밀번호가 현재 비밀번호와 다르면
            if (newPW != self.currentPW) {
                if (self.type == "teacher") { // 선생님인 경우, 선생님 정보 저장 메소드로 정보 저장
                    saveInfo(name, newPW, parentPW)
                } else if (self.type == "student") { // 학생인 경우, 학생 정보 저장 메소드로 정보 저장
                    saveStudentInfo(name, newPW)
                } else if (self.type == "parent") {
                    saveParentInfo(name, newPW, parentPW)
                }
                
                // 새로운 비밀번호로 지정
                Auth.auth().currentUser?.updatePassword(to: newPW) { error in
                    print("error")
                }
                
                // 비밀번호가 수정되었다면 로그인 화면으로 이동
                guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
                
                loginVC.modalPresentationStyle = .fullScreen
                loginVC.modalTransitionStyle = .crossDissolve
                loginVC.isLogouted = true
                
                self.present(loginVC, animated: true, completion: nil)
            } else {
                if (name != "") { // 이름이 공백이 아니면
                    if (self.type == "teacher") { // 선생님인 경우, 선생님 정보 저장 메소드로 정보 저장
                        saveInfo(name, newPW, parentPW)
                    } else if (self.type == "student") { // 학생인 경우, 학생 정보 저장 메소드로 정보 저장
                        saveStudentInfo(name, newPW)
                    } else if (self.type == "parent") {
                        saveParentInfo(name, newPW, parentPW)
                    }
                    
                    if (self.type == "parent") {
                        guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                        tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        self.present(tb, animated: true, completion: nil)
                    } else {
                        
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
                        tb.selectedIndex = 3 // 설정 화면으로 이동
                        self.present(tb, animated: true, completion: nil)
                    }
                }
            }
        } else {
            // 상황에 맞는 오류 메시지 띄우기
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

