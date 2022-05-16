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
    }
    
    /// Load View
    public override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
        
        calendarView.scope = .week
        calendarText(view: calendarView, design: calenderDesign)
        calendarColor(view: calendarView, design: calenderDesign)
        self.calendarEvent()
        
        
        let roundViews: Array<AnyObject> = [progressTextView,evaluationMemoTextView,evaluationOKBtn,monthlyEvaluationOKBtn]
        allRound(views:roundViews,design: btnDesign)
    }
    
    public override func viewDidLoad() {
        
        monthlyEvaluationTextView.textContainerInset = viewDesign.EdgeInsets
        evaluationMemoTextView.textContainerInset = viewDesign.EdgeInsets
        progressTextView.textContainerInset = viewDesign.EdgeInsets
        
        self.monthlyEvaluationOKBtn.isHidden = true
        self.monthlyEvaluationTextView.isHidden = true
        self.monthlyEvaluationQuestionLabel.isHidden = true
        
        self.progressTextView.textColor = .black
        self.evaluationMemoTextView.textColor = .black
        
        let textViews:Array<UITextView> = [progressTextView,evaluationMemoTextView,monthlyEvaluationTextView]
        setBorder(views: textViews, design: viewDesign)
        
        if (self.userName != nil) { // 사용자 이름이 nil이 아닌 경우
            if (self.userType == "student") { // 사용자가 학생이면
                self.questionLabel.text = "오늘 " + self.userName + " 선생님의 수업은 어땠나요?"
                self.classTimeTextField.isEnabled = false
                self.progressLabel.text = "오늘 내용 요약"
                self.homeworkLabel.text = "수업 준비 점수"
                self.evaluationLabel.text = "수업 만족도 점수"
                self.testLabel.text = "수업 난이도 점수"
            } else { // 사용자가 학생이 아니면(선생님이면)
                self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
            }
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
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 사용자의 정보를 가져오도록 하는 메소드
    func getUserInfo() {
//        GetUserInfoInDetailClassVC(self: self)
    }
    
    /// monthly evaluation save button clicked
    @IBAction func SaveMonthlyEvaluation(_ sender: Any) {
        BINDER.SaveMonthlyEvaluation(self: self)
        
        self.monthlyEvaluationOKBtn.isHidden = true
        self.monthlyEvaluationTextView.isHidden = true
    }
    
    /// save evaluation button clicked
    @IBAction func OKButtonClicked(_ sender: Any) {
        SaveDailyEvaluation(self: self)
    }
}

extension DetailClassViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate, UITextViewDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        if (self.userType == "teacher") {
            if (self.currentCnt % 8 == 0 && (self.currentCnt == 0 || self.currentCnt == 8)) {
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
        
        let selectedDate = date
        let nowDate = Date()
        
        // 수업을 하지 않은 미래의 수업에 대해서는 평가를 할 수 없도록 하기 위해서 오늘 날짜와 선택한 날짜 비교
        let distanceDay = Calendar.current.dateComponents([.day], from: selectedDate, to: nowDate).day
        
        // 차이가 0보다 작거나 같으면
        if (!(distanceDay! <= 0)) {
            // 평가 입력 뷰를 숨김 해제
            evaluationView.isHidden = false
            evaluationOKBtn.isHidden = false
            
            self.classTimeTextField.text = ""
            self.resetTextFields()
            
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
    }
    
    public func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool){
        calendarHeight.constant = bounds.height + 20
        self.view.layoutIfNeeded ()
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
