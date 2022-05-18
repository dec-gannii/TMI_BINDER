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
    let notification = PushNotificationSender()
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
    var tname : String!
    var temail: String!
    var fcmtoken: String!
    
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
    
    /// Load View
    public override func viewWillAppear(_ animated: Bool) {
        calendarView.scope = .week
        calendarText(view: calendarView, design: calenderDesign)
//        calendarColor(view: calendarView, design: calenderDesign)
        calendarColor(view: calendarView, design: calenderDesign)
        self.calendarEvent()
        
        let roundViews: Array<AnyObject> = [progressTextView,evaluationMemoTextView,evaluationOKBtn,monthlyEvaluationOKBtn]
        allRound(views:roundViews,design: btnDesign)
    }
    
    public override func viewDidLoad() {
        
        self.classTimeTextField.keyboardType = .numberPad
        self.testScoreTextField.keyboardType = .numberPad
        self.classScoreTextField.keyboardType = .numberPad
        self.homeworkScoreTextField.keyboardType = .numberPad
        
        var textfields = [UITextField]()
        textfields = [self.testScoreTextField, self.classTimeTextField, self.classScoreTextField, self.homeworkScoreTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        monthlyEvaluationTextView.textContainerInset = viewDesign.EdgeInsets
        evaluationMemoTextView.textContainerInset = viewDesign.EdgeInsets
        progressTextView.textContainerInset = viewDesign.EdgeInsets
        
        self.monthlyEvaluationOKBtn.isHidden = true
        self.monthlyEvaluationTextView.isHidden = true
        self.monthlyEvaluationQuestionLabel.isHidden = true
        
        self.progressTextView.textColor = .black
        self.evaluationMemoTextView.textColor = .black
        
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
        
        let textViews:Array<UITextView> = [progressTextView,evaluationMemoTextView,monthlyEvaluationTextView]
        setBorder(views: textViews, design: viewDesign)
        
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
    
    /// monthly evaluation save button clicked
    @IBAction func SaveMonthlyEvaluation(_ sender: Any) {
        BINDER.SaveMonthlyEvaluation(self: self)
        
        self.monthlyEvaluationOKBtn.isHidden = true
        self.monthlyEvaluationTextView.isHidden = true
    }
    
    /// save evaluation button clicked
    @IBAction func OKButtonClicked(_ sender: Any) {
        SaveDailyEvaluation(self: self)
        var payfor = notiForParent()
        if payfor == true {
            getNameFcm()
            notification.sendPushNotification(token: fcmtoken, title: "입금기간이에요!", body: "\(tname!) 선생님의 입금날짜가 되었어요.")
        }
    }
    
    func notiForParent() -> Bool {
        var notibool : Bool!
        
        let db = Firestore.firestore()
        // 경로는 각 학생의 class의 Evaluation
        if(self.userType == "teacher") {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    var currentCnt = data?["currentCnt"] as? Int ?? 0
                    var totalCnt = data?["totalCnt"] as? Int ?? 0
                    
                    if currentCnt == totalCnt {
                        notibool = true
                    } else{
                        notibool = false
                    }
                    
                } else {
                    print("Document does not exist")
                }
            }
        }
        return notibool
    }
    
    func getNameFcm(){
        let db = Firestore.firestore()
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.tname = data?["name"] as? String ?? ""
                self.temail = data?["email"] as? String ?? ""
                
            } else {
                print("Document does not exist")
            }
        }
        db.collection("parent").whereField("teacherEmail", isEqualTo: self.temail!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    /// 문서 존재하면
                    for document in querySnapshot!.documents {
                        self.fcmtoken = document.data()["fcmToken"] as? String ?? ""
                    }
                }
            }
        }
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
            if (self.evaluationView.isHidden == true) {
                self.evaluationView.isHidden = false
                self.evaluationOKBtn.isHidden = false
            } else {
                self.evaluationView.isHidden = true
                self.evaluationOKBtn.isHidden = true
            }
            
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
