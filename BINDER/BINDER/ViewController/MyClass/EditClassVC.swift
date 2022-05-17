//
//  editClassVC.swift
//  BINDER
//
//  Created by 하유림 on 2022/03/09.
//

import UIKit
import Firebase

public class EditClassVC : UIViewController {
    
    // 연결
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var payTypeBtn: UIButton!
    @IBOutlet weak var payAmountTF: UITextField!
    @IBOutlet weak var payDateTF: UITextField!
    @IBOutlet weak var payTypeLb: UILabel!
    @IBOutlet weak var repeatYNToggle: UISwitch!
    @IBOutlet var daysBtn: [UIButton]!
    
    var functionShare = FunctionShare()
    var schedule = ""
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelBtnAction(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func payTypeAction(_ sender: Any) {
        
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
    @IBOutlet weak var okBtn: UIButton!
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func mondayBtn(_ sender: Any) {
        let index = (sender as AnyObject).tag!
        
        switch index {
        case 0...6 :
            if daysBtn[index].isSelected {
                daysBtn[index].isSelected = false
            } else {
                daysBtn[index].isSelected = true
            }
            break
        default:
            let alert = UIAlertController(title: "오류", message: "일정이 선택되지 않았습니다!", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
            alert.addAction(okAction)
            self.present(alert, animated: false, completion: nil)
            break
            
        }
    }
    
    var payType: PayType = .countly {
        didSet {
            changeUI()
        }
    }
    
    func changeUI() {
        switch payType {
        case .countly:
            payTypeLb.text = "회당"
            payTypeBtn.setTitle("회차별", for: .normal)
            
        case .timly:
            payTypeLb.text = "시간당"
            payTypeBtn.setTitle("시간별", for: .normal)
            
        }
    }
    
    @IBAction func okBtnAction(_ sender: Any) {
        for index in 0...daysBtn.count-1 {
            if daysBtn[index].isSelected == true {
                schedule += "\((daysBtn[index].titleLabel?.text)!) "
            }
        }
        UpdateClassInfo(self: self, schedule: schedule)
        
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    // 이 부분 주석 처리 해제해야 1 코드 적용 했을 때 정상 작동
    var userName = ""
    var userEmail = ""
    var userSubject = ""
    
    var subject = ""
    var payAmount = ""
    var payDate = ""
    var days : [String] = []
    var studentItem: StudentItem!
    
    var repeatYN :Bool {
        return repeatYNToggle.isOn
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var textfields = [UITextField]()
        textfields = [self.subjectTF, self.payDateTF, self.payAmountTF]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        box.allRound()
        GetClassInfo(self: self)
    }
}

extension String {
    func getChar(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
