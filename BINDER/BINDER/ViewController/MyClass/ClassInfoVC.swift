//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit
import Firebase

class ClassInfoVC: BaseVC {
    
    
    @IBOutlet weak var classColor: UIView!
    @IBOutlet weak var studentBox: UIView!
    @IBOutlet weak var classInputBox: UIView!
    @IBOutlet weak var studentEmail: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var studentGoal: UILabel!
    @IBOutlet weak var payTypeLb: UILabel!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var togglePayBtn: UIButton!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var creditDayTextField: UITextField!
    @IBOutlet weak var bottomConst:NSLayoutConstraint!
    @IBOutlet weak var contentSv: UIScrollView!
    @IBOutlet weak var isRepeat: UISwitch!
    @IBOutlet var days : [UIButton]!
    
    var studentCount = 0
    
    let classColor1 = ColorUtils.randomColor()
    
    var payType: PayType = .countly {
        didSet {
            changeUI()
        }
    }
    
    weak var delegate: AddStudentDelegate?
    
    var studentItem: StudentItem!
    
    // MARK: - 라이프 사이클
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 둥근 테두리 주기
        classColor.makeCircle()
        
        if let hex = Int(classColor1, radix: 16) {
            classColor.backgroundColor = UIColor.init(rgb: hex)
        } else {
            classColor.backgroundColor = UIColor.red
        }
        
        studentBox.allRound()
        classInputBox.allRound()
        
        /// 학생 정보 셋팅
        studentEmail.text = studentItem.email
        studentName.text = "\(studentItem.name) 학생"
        studentGoal.text = studentItem.goal
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        /// 키보드 올라올 때 화면 쉽게 이동할 수 있도록 해주는 것, 키보드 높이만큼 padding
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    /// 키보드 올라올때 처리
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = contentSv.contentInset
        
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        contentInset.bottom = keyboardFrame.size.height + bottomPadding
        contentSv.contentInset = contentInset
    }
    
    /// 키보드 내려갈때 처리
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        contentSv.contentInset = contentInset
    }
    
    /// 과외비 종류별 처리(화면)
    func changeUI() {
        switch payType {
        case .countly:
            payTypeLb.text = "회당"
            togglePayBtn.setTitle("회차별", for: .normal)
        case .timly:
            payTypeLb.text = "시간당"
            togglePayBtn.setTitle("시간별", for: .normal)
        }
    }
    
    /// 과외일정 정보
    /// - Returns: 과외일정 결과
    func getSchedule() -> String {
        var res: String = ""
        for button in days {
            if let label = button.titleLabel, let title = label.text, button.isSelected, !title.isEmpty {
                res.append(title)
            }
        }
        return res
    }
}



// MARK: - 클릭 이벤트

extension ClassInfoVC {
    /// 저장하기 클릭
    func getStudentClassCount(_ uid: String) {
        let db = Firestore.firestore()
        self.studentCount = 0
        db.collection("student").document(uid).collection("class").getDocuments()
        {
            (querySnapshot, err) in
            
            if let err = err
            {
                print("Error getting documents: \(err)");
            }
            else
            {
                var count = 0
                for document in querySnapshot!.documents {
                    count += 1
                    print("student \(document.documentID) => \(document.data())");
                }
                if (count > 0) {
                    db.collection("student").document(uid).collection("class").document("\(LoginRepository.shared.teacherItem!.name)(\(LoginRepository.shared.teacherItem!.email)) " + self.subjectTextField.text!).updateData(["index": count-1])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                }
            }
        }
    }
    
    func getTeacherClassCount() {
        let db = Firestore.firestore()
        self.studentCount = 0
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments()
        {
            (querySnapshot, err) in
            
            if let err = err
            {
                print("Error getting documents: \(err)");
            }
            else
            {
                var count = 0
                
                for document in querySnapshot!.documents {
                    count += 1
                    print("\(document.documentID) => \(document.data())");
                }
                if (count > 0) {
                    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.studentItem.name + "(" + self.studentItem.email + ") " + self.subjectTextField.text!).updateData(["index": count-1])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                    
                }
            }
        }
    }
    
    /// - Parameter sender: 버튼
    @IBAction func onClickSave(_ sender: UIButton) {
        // 키보드 내려가기
        dismissKeyboard()
        
        guard let subject = subjectTextField.text, !subject.isEmpty else {
            showDefaultAlert(msg: "과목을 입력해주세요.")
            return
        }
        
        guard let payment = moneyTextField.text, !payment.isEmpty else {
            showDefaultAlert(msg: "과외비를 입력해주세요.")
            return
        }
        
        guard let payDate = creditDayTextField.text, !payDate.isEmpty else {
            showDefaultAlert(msg: "정산일을 입력해주세요.")
            return
        }
        
        let schedule = getSchedule()
        guard !schedule.isEmpty else {
            showDefaultAlert(msg: "과외일정을 입력해주세요.")
            return
        }
        
        // 데이터베이스 연결
        var studentUid = ""
        let db = Firestore.firestore()
        
        db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments {
            (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    db.collection("student").whereField("email", isEqualTo: "\(self.studentItem.email)").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    studentUid = document.data()["uid"] as? String ?? ""
                                    
                                    db.collection("student").document(studentUid).collection("class").document("\(LoginRepository.shared.teacherItem!.name)(\(LoginRepository.shared.teacherItem!.email)) " + self.subjectTextField.text!).setData([
                                        "email" : "\(LoginRepository.shared.teacherItem!.email)",
                                        "name" : "\(LoginRepository.shared.teacherItem!.name)",
                                        "subject" : self.subjectTextField.text!,
                                        "currentCnt" : 0,
                                        "totalCnt" : 8,
                                        "circleColor" : self.classColor1,
                                        "recentDate" : "",
                                        "datetime": Date().formatted() ])
                                    { err in
                                        if let err = err {
                                            print(">>>>> document 에러 : \(err)")
                                            self.showDefaultAlert(msg: "수업 저장 중에 에러가 발생했습니다.")
                                        }
                                    }
                                }
                                self.getStudentClassCount(studentUid)
                            }
                        }
                    }
                }
            }
        }
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.studentItem.name + "(" + self.studentItem.email + ") " + self.subjectTextField.text!).setData([
            "email" : self.studentItem.email,
            "name" : self.studentItem.name,
            "goal" : self.studentItem.goal,
            "subject" : subject,
            "currentCnt" : 0,
            "totalCnt" : 8,
            "circleColor" : self.classColor1,
            "recentDate" : "",
            "payType" : self.payType == .timly ? "T" : "C",
            "payDate": payDate,
            "payAmount": payment,
            "schedule" : schedule,
            "repeatYN": self.isRepeat.isOn,
            "datetime": Date().formatted()])
        { err in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "수업 저장 중에 에러가 발생했습니다.")
            } else {
                // 데이타 저장에 성공한 경우 처리
                ///  dissmiss 닫음
                /// completion :클로저
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                    self.delegate?.onSuccess()
                })
            }
        }
        
        self.getTeacherClassCount()
    }
    
    /// 과외비 버튼 클릭
    @IBAction func onClickPay() {
        /// 한번 눌렀을 때 바로 구별할 수 있는 액션시트 나올 수 있게끔 설정
        let alert = UIAlertController(title: "과외비 타입 선택", message: "과외비 정산방식을 선택해 주세요.", preferredStyle: .actionSheet)
        let count = UIAlertAction(title: "회차별", style: .default, handler: { action in
            self.payType = PayType.countly
        })
        let time = UIAlertAction(title: "시간별", style: .default, handler: { action in
            self.payType = PayType.timly
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: { action in
        })
        alert.addAction(count)
        alert.addAction(time)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: {
        })
    }
    
    /// 과외 일정 클릭
    /// - Parameter sender: 버튼
    @IBAction func onClickDay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
}
