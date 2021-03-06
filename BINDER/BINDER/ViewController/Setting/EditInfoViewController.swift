import UIKit
import Firebase

class EditInfoViewController: UIViewController {
    var ref: DatabaseReference!
    var type = ""
    var currentPW = ""
    var functionShare = FunctionShare()
    var settingDB = SettingDBFunctions()
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordCheck: UITextField!
    @IBOutlet weak var parentPassword: UITextField!
    @IBOutlet weak var parentPasswordLabel: UILabel!
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 키보드 올라올때 처리
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillShow(notification:NSNotification) {
        if (self.parentPassword.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.parentPassword.frame.height + 30)
        } else if (self.newPasswordCheck.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.newPasswordCheck.frame.height + 40)
        } else if (self.newPassword.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.newPassword.frame.height + 50)
        }
    }
    
    /// 키보드 내려갈때 처리
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.frame.origin.y = 0 // Move view 150 points upward
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 키보드 띄우기
        self.nameTextField.becomeFirstResponder()
        
        var textfields = [UITextField]()
        textfields = [self.nameTextField, self.newPassword, self.newPasswordCheck, self.parentPassword]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        self.currentPW = sharedCurrentPW
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        /// 키보드 올라올 때 화면 쉽게 이동할 수 있도록 해주는 것, 키보드 높이만큼 padding
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingDB.GetUserInfoForEditInfo(nameTF: self.nameTextField, emailLabel: self.emailLabel, parentPassword: self.parentPassword, parentPasswordLabel: self.parentPasswordLabel)
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
        if (userType == "teacher"){
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
                // 새롭게 변경할 비밀번호와 새롭게 변경할 비밀번호 확인이 모두 공백이거나 새로운 비밀번호가
                //  현재 비밀번호와 동일하면 새로운 비밀번호를 현재 비밀번호로 설정
                newPW = self.currentPW
            }
            // 만약 새로운 비밀번호가 현재 비밀번호와 다르면
            if (newPW != self.currentPW) {
                if (userType == "teacher") { // 선생님인 경우, 선생님 정보 저장 메소드로 정보 저장
                    settingDB.SaveTeacherInfos(name: name, password: newPW, parentPW: parentPW)
                } else if (userType == "student") { // 학생인 경우, 학생 정보 저장 메소드로 정보 저장
                    settingDB.SaveStudentInfos(name: name, password: newPW, parentPassword: self.parentPassword)
                } else if (userType == "parent") {
                    settingDB.SaveParentInfos(name: name, password: newPW, childPhoneNumber: parentPW)
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
                    if (userType == "teacher") { // 선생님인 경우, 선생님 정보 저장 메소드로 정보 저장
                        settingDB.SaveTeacherInfos(name: name, password: newPW, parentPW: parentPW)
                    } else if (userType == "student") { // 학생인 경우, 학생 정보 저장 메소드로 정보 저장
                        settingDB.SaveStudentInfos(name: name, password: newPW, parentPassword: self.parentPassword)
                    } else if (userType == "parent") {
                        settingDB.SaveParentInfos(name: name, password: newPW, childPhoneNumber: parentPW)
                    }
                    
                    if (userType == "parent") {
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
                let alert = UIAlertController(title: "오류", message:  StringUtils.wrongPassword.rawValue, preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) {
                    (action) in
                    self.newPassword.text = ""
                    self.newPasswordCheck.text = ""
                }
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
            } else if (!self.CheckName()) {
                let alert = UIAlertController(title: "오류", message:  StringUtils.nameValidationAlert.rawValue, preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) {
                    (action) in
                    self.nameTextField.text = ""
                }
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
            } else if (!self.CheckParentPW()) {
                let alert = UIAlertController(title: "오류", message: StringUtils.wrongpPasswrod.rawValue, preferredStyle: UIAlertController.Style.alert)
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
