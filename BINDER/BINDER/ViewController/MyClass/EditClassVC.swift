//
//  editClassVC.swift
//  BINDER
//
//  Created by 하유림 on 2022/03/09.
//

import UIKit
import Firebase

class EditClassVC : UIViewController {
    
    // 연결
    
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var payTypeBtn: UIButton!
    @IBOutlet weak var payAmountTF: UITextField!
    @IBOutlet weak var payDateTF: UITextField!
    @IBOutlet weak var payTypeLb: UILabel!
    @IBOutlet weak var repeatYNToggle: UISwitch!
    @IBOutlet var daysBtn: [UIButton]!
    
    var schedule = ""
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelBtnAction(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
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
    
    
    @IBAction func mondayBtn(_ sender: Any) {
        if daysBtn[0].isSelected {
            daysBtn[0].isSelected = false
        } else {
            daysBtn[0].isSelected = true
        }
    }
    
    @IBAction func tuesdayBtn(_ sender: Any) {
        if daysBtn[1].isSelected {
            daysBtn[1].isSelected = false
        } else {
            daysBtn[1].isSelected = true
        }
    }
    
    @IBAction func wednesdayBtn(_ sender: Any) {
        if daysBtn[2].isSelected {
            daysBtn[2].isSelected = false
        } else {
            daysBtn[2].isSelected = true
        }
    }
    
    @IBAction func thursdayBtn(_ sender: Any) {
        if daysBtn[3].isSelected {
            daysBtn[3].isSelected = false
        } else {
            daysBtn[3].isSelected = true
        }
    }
    
    @IBAction func fridayBtn(_ sender: Any) {
        if daysBtn[4].isSelected {
            daysBtn[4].isSelected = false
        } else {
            daysBtn[4].isSelected = true
        }
    }
    
    @IBAction func saturdayBtn(_ sender: Any) {
        if daysBtn[5].isSelected {
            daysBtn[5].isSelected = false
        } else {
            daysBtn[5].isSelected = true
        }
    }
    
    @IBAction func sundayBtn(_ sender: Any) {
        if daysBtn[6].isSelected {
            daysBtn[6].isSelected = false
        } else {
            daysBtn[6].isSelected = true
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
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
            "subject": subjectTF.text ?? "None",
            "payType": self.payType == .timly ? "T" : "C",
            "payAmount": payAmountTF.text ?? "None",
            "payDate": payDateTF.text ?? "None",
            "repeatYN": repeatYN ?? true,
            "schedule": schedule ?? "None"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        
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
    var repeatYN :Bool {
        return repeatYNToggle.isOn
    }
    var days : [String] = []
    
    // var teacherItem: TeacherItem!
    var studentItem: StudentItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        box.allRound()
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let subject = data?["subject"] as? String ?? ""
                self.subjectTF.text = subject
                
                let payType = data?["payType"] as? String ?? ""
                if (payType == "C") {
                    self.payTypeBtn.setTitle("회차별", for: .normal)
                } else {
                    self.payTypeBtn.setTitle("시간별", for: .normal)
                }
                
                let payAmount = data?["payAmount"] as? String ?? ""
                self.payAmountTF.text = payAmount
                
                let payDate = data?["payDate"] as? String ?? ""
                self.payDateTF.text = payDate
                
                let repeatYN = data?["repeatYN"] as? Bool ?? true
                if (repeatYN == true) {
                    self.repeatYNToggle.setOn(true, animated: true)
                } else {
                    self.repeatYNToggle.setOn(false, animated: true)
                }
                
                let schedule = data?["schedule"] as? String ?? ""
                // 저장된 스케줄을 " " 단위로 갈라내어 배열로 저장함
                days = schedule.components(separatedBy: " ")
                print(days)
                
                if days.contains("월") {
                    self.daysBtn[0].isSelected = true
                }
                if days.contains("화") {
                    self.daysBtn[1].isSelected = true
                }
                if days.contains("수") {
                    self.daysBtn[2].isSelected = true
                }
                if days.contains("목") {
                    self.daysBtn[3].isSelected = true
                }
                if days.contains("금") {
                    self.daysBtn[4].isSelected = true
                }
                if days.contains("토") {
                    self.daysBtn[5].isSelected = true
                }
                if days.contains("일") {
                    self.daysBtn[6].isSelected = true
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

extension String {
    func getChar(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
