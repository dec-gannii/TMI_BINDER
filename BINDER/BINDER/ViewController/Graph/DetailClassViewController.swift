//
//  DetailClassViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/26.
//

import UIKit
import Firebase
import FSCalendar
import Charts
import BLTNBoard

public class DetailClassViewController: UIViewController {
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    /// 변수 선언
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var homeworkLabel: UILabel!
    @IBOutlet weak var evaluationLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationQuestionLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    @IBOutlet weak var evaluationView: UIStackView!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var progressTextView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var testScoreTextField: UITextField!
    @IBOutlet weak var evaluationMemoTextView: UITextView!
    @IBOutlet weak var evaluationOKBtn: UIButton!
    @IBOutlet weak var homeworkScoreTextField: UITextField!
    @IBOutlet weak var classScoreTextField: UITextField!
    @IBOutlet weak var classTimeTextField: UITextField!
    @IBOutlet weak var monthlyEvaluationOKBtn: UIButton!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var currentCnt: Int!
    var count: Int!
    var bRec: Bool!
    var date: String!
    var selectedMonth: String!
    var userIndex: Int!
    var keyHeight: CGFloat?
    var dateStrWithoutDays: String!
    var teacherUid: String!
    var studentName: String!
    var studentEmail: String!
    var viewDesign = ViewDesign()
    var calenderDesign = CalendarDesign()
    var btnDesign = ButtonDesign()
    var functionShare = FunctionShare()
    var payType: String!
    var tname: String!
    var temail: String!
    var fcmToken: String!
    
    let nowDate = Date()
    
    func _init(){
        userEmail = ""
        userSubject = ""
        userName = ""
        userType = ""
        currentCnt = 0
        count = 0
        bRec = false
        date = ""
        selectedMonth = ""
        userIndex = 0
        keyHeight = 0.0
        dateStrWithoutDays = ""
        teacherUid = ""
        studentName = ""
        studentEmail = ""
        payType = ""
    }
    
    func placeholderSetting(_ textView: UITextView) {
        textView.delegate = self // 유저가 선언한 outlet
        if textView.text.isEmpty || textView.text == "" {
            if (textView == self.progressTextView) {
                textView.text = StringUtils.progressText.rawValue
            } else if (textView == self.monthlyEvaluationTextView) {
                textView.text = StringUtils.monthlyEvaluation.rawValue
            }
            textView.textColor = UIColor.lightGray
        } else {
            textView.textColor = UIColor.black
        }
    }
    
    // TextView Place Holder
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // TextView Place Holder
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            if (textView == self.progressTextView) {
                textView.text = StringUtils.progressText.rawValue
            } else if (textView == self.monthlyEvaluationTextView) {
                textView.text = StringUtils.monthlyEvaluation.rawValue
            }
            textView.textColor = UIColor.lightGray
        } else {
            textView.textColor = UIColor.black
        }
    }
    
    func calendarText(view:FSCalendar, design:CalendarDesign) {
        view.headerHeight = CGFloat(18)
        view.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        view.appearance.headerMinimumDissolvedAlpha = 0.0
        view.appearance.headerDateFormat = "YYYY년 M월"
        view.appearance.titleFont = UIFont.systemFont(ofSize: 14)
        view.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
        view.locale = Locale(identifier: "ko_KR")
        view.weekdayHeight = CGFloat(40)
    }
    
    /// Load View
    public override func viewWillAppear(_ animated: Bool) {
        calendarView.scope = .week
        self.calendarText(view: calendarView, design: calenderDesign)
        calendarColor(view: calendarView, design: calenderDesign)
        self.calendarEvent()
        let color = UIColor(red: 84, green: 83, blue: 87, alpha: 1.0)
        self.calendarView.appearance.borderSelectionColor = UIColor(red: 1, green: 104, blue: 255, alpha: 0.6)
        self.calendarView.appearance.weekdayTextColor = color
        self.calendarView.appearance.titleWeekendColor = color
        self.calendarView.appearance.headerTitleColor =  color
        
        let roundViews: Array<AnyObject> = [progressTextView,evaluationMemoTextView,evaluationOKBtn,monthlyEvaluationOKBtn]
        allRound(views:roundViews,design: btnDesign)
    }
    
    public override func viewDidLoad() {
        let dateFormatter = DateFormatter()
        self.evaluationMemoTextView.textColor = .black
        
        dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateStr = dateFormatter.string(from: nowDate)
        self.date = dateStr
        
        GetEvaluations(self: self, dateStr: dateStr)
        
        self.classTimeTextField.keyboardType = .numberPad
        self.testScoreTextField.keyboardType = .numberPad
        self.classScoreTextField.keyboardType = .numberPad
        self.homeworkScoreTextField.keyboardType = .numberPad
        
        var textfields = [UITextField]()
        textfields = [self.testScoreTextField, self.classTimeTextField, self.classScoreTextField, self.homeworkScoreTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        getNameFcm()
        monthlyEvaluationTextView.textContainerInset = viewDesign.EdgeInsets
        evaluationMemoTextView.textContainerInset = viewDesign.EdgeInsets
        progressTextView.textContainerInset = viewDesign.EdgeInsets
        
        self.monthlyEvaluationOKBtn.isHidden = true
        self.monthlyEvaluationTextView.isHidden = true
        self.monthlyEvaluationQuestionLabel.isHidden = true
        
        if (self.payType == "T") {
            self.classTimeTextField.isEnabled = true
        } else if (self.payType == "C") {
            self.classTimeTextField.isEnabled = false
        }
        
        if self.userType == "teacher" {
            self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
        } else {
            self.questionLabel.text = "오늘 " + self.userName + " 선생님의 수업은 어땠나요?"
            self.classTimeTextField.isEnabled = false
            self.progressLabel.text = "오늘 내용 요약"
            self.homeworkLabel.text = "수업 준비 점수"
            self.evaluationLabel.text = "수업 만족도 점수"
            self.testLabel.text = "수업 난이도 점수"
        }
        
        super.viewDidLoad()
    }
    
    func resetTextFields() {
        // 값 다시 공백 설정
        self.progressTextView.text = ""
        self.testScoreTextField.text = ""
        self.evaluationMemoTextView.text = ""
        self.homeworkScoreTextField.text = ""
        self.classScoreTextField.text = ""
        placeholderSetting(self.progressTextView)
        placeholderSetting(self.monthlyEvaluationTextView)
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
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
        if (self.monthlyEvaluationTextView.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.monthlyEvaluationTextView.frame.height + 20)
        } else {
            self.view.frame.origin.y = 0 // Move view 150 points upward
        }
    }
    
    /// 키보드 내려갈때 처리
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.frame.origin.y = 0 // Move view 150 points upward
    }
    
    /// monthly evaluation save button clicked
    @IBAction func SaveMonthlyEvaluation(_ sender: Any) {
        BINDER.SaveMonthlyEvaluation(self: self)
        
        self.monthlyEvaluationOKBtn.isHidden = true
        self.monthlyEvaluationTextView.isHidden = true
        self.monthlyEvaluationQuestionLabel.isHidden = true
    }
    
    /// save evaluation button clicked
    @IBAction func OKButtonClicked(_ sender: Any) {
        SaveDailyEvaluation(self: self)
    }
    
    func getNameFcm(){
        let db = Firestore.firestore()
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.tname = data?["name"] as? String ?? ""
                self.temail = data?["email"] as? String ?? ""
                
                db.collection("parent").whereField("teacherEmail", isEqualTo: self.temail!).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        if let err = err {
                            print("Error getting documents(inMyClassView): \(err)")
                        } else {
                            /// 문서 존재하면
                            for document in querySnapshot!.documents {
                                self.fcmToken = document.data()["fcmToken"] as? String ?? ""
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

extension DetailClassViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate, UITextViewDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        if (self.userType == "teacher") {
            self.evaluationView.isHidden = false
            self.evaluationOKBtn.isHidden = false
            
            if (self.currentCnt % 8 == 0 && (self.currentCnt == 0 || self.currentCnt == 8)) {
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                self.view.addGestureRecognizer(tap)
                
                /// 키보드 올라올 때 화면 쉽게 이동할 수 있도록 해주는 것, 키보드 높이만큼 padding
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
                
                self.monthlyEvaluationQuestionLabel.isHidden = false
                self.monthlyEvaluationOKBtn.isHidden = false
                self.monthlyEvaluationTextView.isHidden = false
            } else {
                self.monthlyEvaluationQuestionLabel.isHidden = true
                self.monthlyEvaluationOKBtn.isHidden = true
                self.monthlyEvaluationTextView.isHidden = true
            }
        } else {
            self.monthlyEvaluationQuestionLabel.isHidden = true
            self.monthlyEvaluationOKBtn.isHidden = true
            self.monthlyEvaluationTextView.isHidden = true
        }
        
//        if self.evaluationView.isHidden == true {
        self.evaluationView.isHidden = false
        self.evaluationOKBtn.isHidden = false
//        }
        
        let selectedDate = date
        
        self.progressTextView.endEditing(true)
        self.monthlyEvaluationTextView.endEditing(true)
        
        // 날짜 받아와서 변수에 저장
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateStr = dateFormatter.string(from: selectedDate)
        self.date = dateStr
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateStrWithoutDays = dateFormatter.string(from: selectedDate)
        self.dateStrWithoutDays = dateStrWithoutDays
        
        dateFormatter.dateFormat = "MM"
        let monthStr = dateFormatter.string(from: selectedDate)
        self.selectedMonth = monthStr
        
        GetEvaluations(self: self, dateStr: dateStr)
    }
    
    public func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool){
        calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(backgroundImage, for: state)
    }
}

extension DetailClassViewController: FSCalendarDataSource {
    
}
