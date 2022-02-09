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
    
    //    var userName = ""
    //    var userEmail = ""
    //    var parentPW = ""
    var type = ""
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordCheck: UITextField!
    @IBOutlet weak var parentPassword: UITextField!
    
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
        let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
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
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // 정보 저장하는 메소드
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
    
    @IBAction func CancelBtnClicked(_ sender: Any) {
        //        guard let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        //
        //        settingVC.modalPresentationStyle = .fullScreen
        //        settingVC.modalTransitionStyle = .crossDissolve
        //
        //        self.present(settingVC, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OKBtnClicked(_ sender: Any) {
        var name = ""
        var newPW = ""
        var parentPW = parentPassword.text ?? ""
        
        if (newPassword.text == newPasswordCheck.text) {
            if (isValidName(nameTextField.text!) && isValidPassword(newPassword.text!)) {
                name = self.nameTextField.text!
                newPW = self.newPassword.text!
                Auth.auth().currentUser?.updatePassword(to: newPW) { error in
                  print("error")
                }
                
                if (parentPassword.text!.count <= 6) {
                    if let convertedNum = Int(parentPW) {
                        print("\(convertedNum)")
                    } else {
                        let alert = UIAlertController(title: "오류", message: "학부모 비밀번호가 올바른 형식이 아닙니다!", preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) {
                            (action) in
                            self.parentPassword.text = ""
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "오류", message: "유효한 이름 또는 비밀번호가 아닙니다!", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { [self]
                    (action) in
                    if (!self.isValidName(self.nameTextField.text!)) {
                        self.nameTextField.text = ""
                    } else if (!self.isValidPassword(self.newPassword.text!)) {
                        self.newPassword.text = ""
                        self.newPasswordCheck.text = ""
                    }
                }
            }
        }
        
        if (name != "" && newPW != "" && parentPW != "") {
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
//
//            guard let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
//
//            settingVC.modalPresentationStyle = .fullScreen
//            settingVC.modalTransitionStyle = .crossDissolve
//
//            self.present(settingVC, animated: true, completion: nil)
        }
    }
}

