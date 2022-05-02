//
//  AddScheduleViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/23.
//
// 일정 추가 화면

import UIKit
import Firebase

class AddScheduleViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scheduleTitle: UITextField!
    @IBOutlet weak var schedulePlace: UITextField!
    @IBOutlet weak var scheduleTime: UITextField!
    @IBOutlet weak var scheduleMemo: UITextView!
    @IBOutlet weak var okBtn: UIButton!
    
    var date: String!
    var editingTitle: String!
    var isEditMode: Bool = false
    var savedTime: String = ""
    var type: String = ""
    var viewDesign = ViewDesign()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateLabel.text = date
        self.scheduleMemo.layer.borderWidth = viewDesign.borderWidth
        self.scheduleMemo.layer.borderColor = viewDesign.borderColor
        
        // 만약 넘어온 수정할 제목이 넘어와서 nil이 아니라면,
        if (self.editingTitle != nil) {
            // 버튼의 타이틀을 일정 수정하기로 변경
            self.okBtn.setTitle("일정 수정하기", for: .normal)
            
<<<<<<< Updated upstream
            // 내용이 있다는 의미이므로 데이터베이스에서 다시 받아와서 textfield의 값으로 설정
            self.db.collection(self.type).document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList").document(self.editingTitle).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.isEditMode = true
                    let data = document.data()
                    let memo = data?["memo"] as? String ?? ""
                    self.scheduleMemo.text = memo
                    let place = data?["place"] as? String ?? ""
                    self.schedulePlace.text = place
                    let title = data?["title"] as? String ?? ""
                    self.scheduleTitle.text = title
                    let time = data?["time"] as? String ?? ""
                    self.scheduleTime.text = time
                } else {
                    print("Document does not exist")
                }
            }
            
=======
            GetBeforeEditSchedule(type: self.type, date: self.date, editingTitle: self.editingTitle, scheduleMemo: self.scheduleMemo, schedulePlace: self.schedulePlace, scheduleTitle: self.scheduleTitle, scheduleTime: self.scheduleTime)
        } else {
            varIsEditMode = false
>>>>>>> Stashed changes
        }
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 취소 버튼 클릭 시 실행되는 메소드
    @IBAction func CancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 추가 버튼 클릭 시 실행되는 메소드
    @IBAction func AddScheduleSubmitBtn(_ sender: Any) {
        // 날짜 받아오기
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "YYYY-MM-dd HH:mm"
        let current_time_string = formatter_time.string(from: Date())
        self.savedTime = current_time_string
        
        let dateWithoutDays = self.date.components(separatedBy: " ")
        formatter_time.dateFormat = "YYYY-MM-dd"
        let date = formatter_time.date(from: dateWithoutDays[0])!
        let datestr = formatter_time.string(from: date)
        
        // 수정 모드라면,
<<<<<<< Updated upstream
        if (isEditMode == true) {
            // 원래 데이터베이스에 저장되어 있던 일정은 삭제하고 새롭게 수정한 내용으로 추가 후 현재 modal dismiss
            self.db.collection(self.type).document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList").document(self.editingTitle).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            self.db.collection(self.type).document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList").document(scheduleTitle.text!).setData([
                "title": scheduleTitle.text!,
                "place": schedulePlace.text!,
                "date" : datestr,
                "time": scheduleTime.text!,
                "memo": scheduleMemo.text!,
                "savedTime": current_time_string ])
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
=======
        if (varIsEditMode == true) {
            SaveEditSchedule(type: self.type, date: self.date, editingTitle: self.editingTitle, isEditMode: self.isEditMode, scheduleMemoTV: self.scheduleMemo, schedulePlaceTF: self.schedulePlace, scheduleTitleTF: self.scheduleTitle, scheduleTimeTF: self.scheduleTime, datestr: datestr, current_time_string: current_time_string)
>>>>>>> Stashed changes
            self.dismiss(animated: true, completion: nil)
        }
        else {
            // 수정 모드가 아니라면,
            if (scheduleTitle.text != "") {
                if ((scheduleTitle.text?.trimmingCharacters(in: .whitespaces)) != "") {
                    SaveSchedule(type: self.type, date: self.date, scheduleTitleTF: self.scheduleTitle, scheduleMemoTV: self.scheduleMemo, schedulePlaceTF: self.schedulePlace, scheduleTimeTF: self.scheduleTime, datestr: datestr, current_time_string: current_time_string)
                }
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
