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
    @IBOutlet weak var dateLabelBGView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    
    var date: String!
    var editingTitle: String!
    var isEditMode: Bool = false
    var savedTime: String = ""
    var type: String = ""
    var viewDesign = ViewDesign()
    var functionShare = FunctionShare()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        /// 키보드 올라올 때 화면 쉽게 이동할 수 있도록 해주는 것, 키보드 높이만큼 padding
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        var textfields = [UITextField]()
        textfields = [self.scheduleTime, self.schedulePlace]
        
        functionShare.textFieldPaddingSetting(textfields)
        /// 키보드 띄우기
        self.scheduleTitle.becomeFirstResponder()
        
        self.dateLabel.text = date
        
        scheduleMemo.layer.cornerRadius = 8
        scheduleTime.layer.cornerRadius = 8
        dateLabelBGView.layer.cornerRadius = 8
        schedulePlace.layer.cornerRadius = 8
        scheduleMemo.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        
        // 만약 넘어온 수정할 제목이 넘어와서 nil이 아니라면,
        if (self.editingTitle != nil) {
            // 버튼의 타이틀을 일정 수정하기로 변경
            self.okBtn.setTitle("일정 수정하기", for: .normal)
            
            // 내용이 있다는 의미이므로 데이터베이스에서 다시 받아와서 textfield의 값으로 설정
            GetBeforeEditSchedule(type: self.type, date: self.date, editingTitle: self.editingTitle, scheduleMemo: self.scheduleMemo, schedulePlace: self.schedulePlace, scheduleTitle: self.scheduleTitle, scheduleTime: self.scheduleTime)
        } else {
            varIsEditMode = false
        }
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 키보드 올라올때 처리
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillShow(notification:NSNotification) {
        if (self.scheduleMemo.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.scheduleMemo.frame.height + 20)
        }
    }
    
    /// 키보드 내려갈때 처리
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.frame.origin.y = 0 // Move view 150 points upward
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
        if (varIsEditMode == true) {
            SaveEditSchedule(type: self.type, date: self.date, editingTitle: self.editingTitle, isEditMode: self.isEditMode, scheduleMemoTV: self.scheduleMemo, schedulePlaceTF: self.schedulePlace, scheduleTitleTF: self.scheduleTitle, scheduleTimeTF: self.scheduleTime, datestr: datestr, current_time_string: current_time_string)
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
