//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit
import Firebase

public class ClassInfoVC: BaseVC {
    @IBOutlet weak var studentBox: UIView!
    @IBOutlet weak var classInputBox: UIView!
    @IBOutlet weak var studentEmail: UILabel!
    @IBOutlet weak var studentName: UILabel!
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
    var functionShare = FunctionShare()
    
    // MARK: - 라이프 사이클
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var textfields = [UITextField]()
        textfields = [self.subjectTextField, self.moneyTextField, self.creditDayTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        /// 학생 정보 셋팅
        studentEmail.text = studentItem.email
        studentName.text = "\(studentItem.name)"
        
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
                res.append("\(title) ")
            }
        }
        return res
    }
}

// MARK: - 클릭 이벤트

extension ClassInfoVC {
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
        
        SaveClassInfo(self: self, subject: subject, payDate: payDate, payment: payment, schedule: schedule)
        GetTeacherClassCount(self: self)
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
