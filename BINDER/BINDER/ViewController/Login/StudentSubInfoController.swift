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

public class StudentSubInfoController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
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
    var tpassword: String = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        if (type == "teacher") {
            ageLabel.text = "학부모 인증 비밀번호"
            ageAlertLabel.text = StringUtils.ageValidationAlert.rawValue
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
            ageAlertLabel.text = StringUtils.ageValidationAlert.rawValue
            ageAlertLabel.isHidden = true
            ageShowPicker.placeholder = "학부모 인증 비밀번호를 입력해주세요."
            phoneLabel.text = "자녀 휴대폰 번호"
            phoneAlertLabel.isHidden = true
            phonenumTextField.placeholder = "자녀의 휴대폰 번호를 입력해주세요."
            goalLabel.text = "선생님 이메일"
            goalAlertLabel.text = StringUtils.tEmailNotExist.rawValue
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
    
    // 이메일 형식인지 검사하는 메소드
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return agelist.count
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        age = agelist[row]
        return agelist[row]
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
        DeleteUser(self: self)
        // 로그인 화면(첫화면)으로 다시 이동
        guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        phonenum = phonenumTextField.text!
        goal = goalTextField.text!
        
        var phoneNumberWithDash = ""
        if (phoneNumberWithDash.contains("-")) {
            phoneNumberWithDash = phonenum
        } else {
            var firstPart = ""
            var secondPart = ""
            var thirdPart = ""
            var count = 0
            
            for char in phonenum{
                if (count >= 0 && count <= 2) {
                    firstPart += String(char)
                } else if (count >= 3 && count <= 6){
                    secondPart += String(char)
                } else if (count >= 7 && count <= 11){
                    thirdPart += String(char)
                }
                count = count + 1
            }
            phoneNumberWithDash = firstPart + " - " + secondPart + " - " + thirdPart
        }
        
        let countOfDigit = countOfDigit()
        if (type == "teacher"){
            pw = Int(ageShowPicker.text!)!
            if (!isValidPw(pw) || countOfDigit > 6) {
                ageAlertLabel.text = StringUtils.passwordValidationAlert.rawValue
                ageAlertLabel.isHidden = false
            } else {
                // 데이터 저장
                ageAlertLabel.isHidden = true
                UpdateTeacherSubInfo(parentPW: ageShowPicker.text!)
                guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else { return }
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                self.present(tb, animated: true, completion: nil)
            }
        } else if (type == "student") {
            if age == "0" {
                ageAlertLabel.text = "나이대를 선택해주세요."
                ageAlertLabel.isHidden = false
            }
            else if phonenum == "" {
                phoneAlertLabel.text = "전화번호를 입력해주세요."
                phoneAlertLabel.isHidden = false
            }
            else if goal == "" {
                goalAlertLabel.text = "목표를 작성해주세요."
                goalAlertLabel.isHidden = false
            }
            else if ((phonenumTextField.text!.contains("-") && phonenumTextField.text!.count >= 15) || (phonenumTextField.text!.count >= 11 && phonenumTextField.text!.contains("-"))) {
                phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                phoneAlertLabel.isHidden = false
            }
            else {
                goalAlertLabel.isHidden = true
                phoneAlertLabel.isHidden = true
                ageAlertLabel.isHidden = true
                // 데이터 저장
                UpdateStudentSubInfo(age: age, phonenum: phoneNumberWithDash, goal: goal)
                guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else { return }
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                self.present(tb, animated: true, completion: nil)
            }
        } else if (type == "parent") {
            // 선생님 이메일 이용한 비밀번호 받아오기
            
            if(isValidEmail(goal)){
                CheckStudentPhoneNumberForParent(phoneNumber: phoneNumberWithDash, self: self, goal: goal)
            } else {
                goalAlertLabel.text = StringUtils.emailValidationAlert.rawValue
                ageAlertLabel.isHidden = false
            }
        }
    }
}



