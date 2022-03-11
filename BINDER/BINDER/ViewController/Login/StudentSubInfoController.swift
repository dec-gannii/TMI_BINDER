//
//  StudentSubInfoController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class StudentSubInfoController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    @IBOutlet weak var ageShowPicker: UITextField!
    @IBOutlet weak var phonenumTextField: UITextField!
    @IBOutlet weak var goalTextField: UITextField!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var goalAlertLabel: UILabel!
    @IBOutlet weak var phoneAlertLabel: UILabel!
    @IBOutlet weak var ageAlertLabel: UILabel!
    
    let agelist = ["초등학생","중학생","고등학생","일반인"]
    var age = "0"
    var phonenum = "0"
    var goal = "0"
    var type: String = ""
    var pw: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        if (type == "teacher") {
            ageLabel.text = "학부모 인증 비밀번호"
            ageAlertLabel.text = "잘못된 입력입니다."
            ageAlertLabel.isHidden = true
            ageShowPicker.placeholder = "학부모 인증에 사용될 비밀번호를 입력해주세요."
            phoneLabel.isHidden = true
            phoneAlertLabel.isHidden = true
            phonenumTextField.isHidden = true
            goalLabel.isHidden = true
            goalAlertLabel.isHidden = true
            goalTextField.isHidden = true
        } else if (type == "parent") {
            ageLabel.text = "학부모 인증 비밀번호"
            ageAlertLabel.text = "잘못된 입력입니다."
            ageAlertLabel.isHidden = true
            ageShowPicker.placeholder = "학부모 인증 비밀번호를 입력해주세요."
            phoneLabel.text = "자녀 휴대폰 번호"
            phoneAlertLabel.isHidden = true
            phonenumTextField.placeholder = "자녀의 휴대폰 번호를 입력해주세요."
            goalLabel.text = "선생님 이메일"
            goalAlertLabel.text = "해당하는 선생님이 존재하지 않습니다!"
            goalAlertLabel.isHidden = true
            goalTextField.placeholder = "선생님의 이메일 주소를 입력해주세요."
        }
        else {
            ageLabel.text = nil
            phoneLabel.text = nil
            goalLabel.text = nil
            
            goalAlertLabel.isHidden = true
            phoneAlertLabel.isHidden = true
            ageAlertLabel.isHidden = true
            
            createPickerView()
            dismissPickerView()
        }
    }
    
    func countOfDigit() -> Int {
        // 숫자의 자릿수를 세는 함수
        var count: Int = 0
        while Int(pw) > 0 {
            pw /= 10
            count += 1
        }
        return count
    }
    
    //  숫자인지를 검사하는 메소드
    func isValidPw(_ pw: Int) -> Bool {
        //         공백 검사
        if (pw == Int(ageShowPicker.text!.trimmingCharacters(in: .whitespaces))) { return true }
        else { return false }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return agelist.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        age = agelist[row]
        return agelist[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ageShowPicker.text = agelist[row]
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        ageShowPicker.tintColor = .clear
        
        ageShowPicker.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBT = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(donePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelBT = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelBT,flexibleSpace,doneBT], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        ageShowPicker.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        ageShowPicker.text = "\(age)"
        self.ageShowPicker.resignFirstResponder()
        
    }
    
    @objc func cancelPicker() {
        ageShowPicker.resignFirstResponder()
    }
    
    @IBAction func goSignInPage(_ sender: Any) {
        let user = Auth.auth().currentUser // 사용자 정보 가져오기
        
        user?.delete { error in
            if let error = error {
                // An error happened.
                print("delete user error : \(error)")
            } else {
                // Account deleted.
                // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
                var docRef = self.db.collection("teacher").document(user!.uid)
                
                docRef.delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                
                docRef = self.db.collection("student").document(user!.uid)
                
                docRef.delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                
                docRef = self.db.collection("parent").document(user!.uid)
                
                docRef.delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
            
            print("delete success, go sign in page")
            
            // 로그인 화면(첫화면)으로 다시 이동
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func goNext(_ sender: Any) {
        phonenum = phonenumTextField.text!
        goal = goalTextField.text!
        let countOfDigit = countOfDigit()
        if (type == "teacher"){
            pw = Int(ageShowPicker.text!)!
            if (!isValidPw(pw) || countOfDigit > 6) {
                ageAlertLabel.text = "올바른 형식의 비밀번호가 아닙니다."
                ageAlertLabel.isHidden = false
            } else {
                // 데이터 저장
                ageAlertLabel.isHidden = true
                db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
                    "parentPW": ageShowPicker.text!
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else { return }
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                self.present(tb, animated: true, completion: nil)
            }
        } else if (type == "student") {
            if age == "0" {
                ageAlertLabel.text = "하나를 선택해주세요"
            }
            else if phonenum == "" {
                phoneAlertLabel.text = "전화번호를 작성해주세요"
            }
            else if goal == "" {
                goalAlertLabel.text = "목표를 작성해주세요"
            }
            else {
                goalAlertLabel.isHidden = true
                phoneAlertLabel.isHidden = true
                ageAlertLabel.isHidden = true
                // 데이터 저장
                db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
                    "age": age,
                    "phonenum": phonenum,
                    "goal": goal
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else { return }
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                self.present(tb, animated: true, completion: nil)
            }
        } else if (type == "parent") {
            guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
            tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            self.present(tb, animated: true, completion: nil)
        }
    }
}

