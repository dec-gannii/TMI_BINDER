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
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var todoTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var homeworkLabel: UILabel!
    @IBOutlet weak var evaluationLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationBackgroundView: UIView!
    @IBOutlet weak var monthlyEvaluationQuestionLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var currentCnt: Int!
    var days: [String]!
    var scores: [Double]!
    var floatValue: [CGFloat]!
    var barColors = [UIColor]()
    var count: Int!
    var todos = Array<String>()
    var todoCheck = Array<Bool>()
    var todoDoc = Array<String>()
    var bRec: Bool!
    var date: String!
    var selectedMonth: String!
    var userIndex: Int!
    var keyHeight: CGFloat?
    var checkTime: Bool!
    var dateStrWithoutDays: String!
    var teacherUid: String!
    var studentName: String!
    var studentEmail: String!
    var viewDesign = ViewDesign()
    var calenderDesign = CalendarDesign()
    var chartDesign = ChartDesign()
    var btnDesign = ButtonDesign()
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var evaluationView: UIView!
    @IBOutlet weak var progressTextView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var testScoreTextField: UITextField!
    @IBOutlet weak var evaluationMemoTextView: UITextView!
    @IBOutlet weak var evaluationOKBtn: UIButton!
    @IBOutlet weak var homeworkScoreTextField: UITextField!
    @IBOutlet weak var classScoreTextField: UITextField!
    @IBOutlet weak var classNavigationBar: UINavigationBar!
    @IBOutlet weak var EvaluationTitleLabel: UILabel!
    @IBOutlet weak var classTimeTextField: UITextField!
    @IBOutlet weak var monthlyEvaluationOKBtn: UIButton!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    func _init(){
        userEmail = ""
        userSubject = ""
        userName = ""
        userType = ""
        currentCnt = 0
        days = []
        scores = []
        floatValue = [5,5]
        barColors = []
        count = 0
        todos = []
        todoCheck = []
        todoDoc = []
        bRec = false
        date = ""
        selectedMonth = ""
        userIndex = 0
        keyHeight = 0.0
        checkTime = false
        dateStrWithoutDays = ""
        teacherUid = ""
        studentName = ""
        studentEmail = ""
        
    }
    
    /// Load View
    public override func viewWillAppear(_ animated: Bool) {
        getScores()
        getUserInfo()
        
        calendarView.scope = .week
        calendarText(view: calendarView, design: calenderDesign)
        calendarColor(view: calendarView, design: calenderDesign)
        self.calendarEvent()
        
        
        okButton.clipsToBounds = true
        plusButton.clipsToBounds = true
        let roundViews: Array<AnyObject> = [
            plusButton,evaluationView,monthlyEvaluationBackgroundView,monthlyEvaluationTextView,progressTextView,evaluationMemoTextView,evaluationOKBtn,monthlyEvaluationOKBtn]
        allRound(views:roundViews,design: btnDesign)
        barColors = barColorSetting(design: chartDesign)
    }
    
    public override func viewDidLoad() {
        // 빈 배열 형성
        days = []
        scores = []
        
        monthlyEvaluationTextView.textContainerInset = viewDesign.EdgeInsets
        evaluationMemoTextView.textContainerInset = viewDesign.EdgeInsets
        progressTextView.textContainerInset = viewDesign.EdgeInsets
        
        self.monthlyEvaluationBackgroundView.isHidden = true
        
        // 데이터 없을 때 나올 텍스트 설정
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        
        self.progressTextView.textColor = .black
        self.evaluationMemoTextView.textColor = .black
        
        let textViews:Array<UITextView> = [progressTextView,evaluationMemoTextView,monthlyEvaluationTextView]
        setBorder(views: textViews, design: viewDesign)
        
        evaluationView.isHidden = true
        evaluationOKBtn.isHidden = true
        
        if (self.userName != nil) { // 사용자 이름이 nil이 아닌 경우
            if (self.userType == "student") { // 사용자가 학생이면
                self.classNavigationBar.topItem!.title = self.userName + " 선생님"
                self.questionLabel.text = "오늘 " + self.userName + " 선생님의 수업은 어땠나요?"
                self.classTimeTextField.isEnabled = false
                self.progressLabel.text = "오늘 내용 요약"
                self.homeworkLabel.text = "수업 준비 점수"
                self.evaluationLabel.text = "수업 만족도 점수"
                self.testLabel.text = "수업 난이도 점수"
            } else { // 사용자가 학생이 아니면(선생님이면)
                self.monthlyEvaluationBackgroundView.isHidden = true
                self.classNavigationBar.topItem!.title = self.userName + " 학생"
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 사용자의 정보를 가져오도록 하는 메소드
    func getUserInfo() {
        GetUserInfoInDetailClassVC(self: self)
    }
    
    /// get student's scores from database
    func getScores() {
        var studentUid = "" // 학생의 uid 변수
        // 빈 배열 형성
        days = []
        scores = []
        
        // 받은 이메일이 nil이 아니라면
        if let email = self.userEmail {
            var studentEmail = ""
            if (self.userType == "student") { // 현재 로그인한 사용자가 학생이라면 현재 사용자의 이메일 받아오기
                studentEmail = (Auth.auth().currentUser?.email)!
            } else { // 아니라면 전 view controller에서 받아온 이메일로 설정
                studentEmail = email
            }

            GetScores(self: self, studentEmail: studentEmail)
        }

    
    /// back button clicked
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    /// monthly evaluation save button clicked
    @IBAction func SaveMonthlyEvaluation(_ sender: Any) {
        BINDER.SaveMonthlyEvaluation(self: self)
        self.monthlyEvaluationBackgroundView.isHidden = true
    }
    
    /// more button (edit or delete class info) clicked
    @IBAction func editBtnAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: "수정 및 삭제", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default, handler: { action in
            guard let editClassVC = self.storyboard?.instantiateViewController(withIdentifier: "EditClassViewController") as? EditClassVC else { return }
            
            editClassVC.modalTransitionStyle = .crossDissolve
            editClassVC.modalPresentationStyle = .fullScreen
            
            // 값 보내주는 역할
            editClassVC.userName = self.userName
            editClassVC.userEmail = self.userEmail
            editClassVC.userSubject = self.userSubject
            
            self.present(editClassVC, animated: true, completion: nil)
        })
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: { action in
            DeleteClass(self: self)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    /// save evaluation button clicked
    @IBAction func OKButtonClicked(_ sender: Any) {
        SaveDailyEvaluation(self: self)
    }
    
    
    /// add score button clicked
    @IBAction func PlusScores(_ sender: Any) {
        guard let plusGraphVC = self.storyboard?.instantiateViewController(withIdentifier: "PlusGraphViewController") as? PlusGraphViewController else { return }
        
        plusGraphVC.modalTransitionStyle = .crossDissolve
        plusGraphVC.modalPresentationStyle = .fullScreen
        
        // 값 보내주는 역할
        plusGraphVC.userName = self.userName
        plusGraphVC.userEmail = self.userEmail
        plusGraphVC.userSubject = self.userSubject
        
        self.present(plusGraphVC, animated: true, completion: nil)
    }
    
    /// add to do list factor button clicked
    @IBAction func goButtonClicked(_ sender: Any) {
        if todoTF.text != "" {
            todos.append(todoTF.text ?? "")
            todoCheck.append(checkTime)
            todoDoc = []
            AddToDoListFactors(self: self, checkTime: checkTime)
            todoTF.text = ""
            self.tableView.reloadData()
        }
    }
}


extension DetailClassViewController:UITableViewDataSource, UITableViewDelegate {
    
    //데이터 카운트
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    // 데이터 나타내기
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as! Todocell
        let todo = self.todos[indexPath.row]
        
        cell.todoLabel.text = "\(todo)"
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(checkMarkButtonClicked(sender:)),for: .touchUpInside)
        
        cell.checkButton.isSelected = todoCheck[indexPath.row]
        cell.checkButton.layer.cornerRadius = cell.checkButton.frame.size.width / 2
        cell.checkButton.layer.masksToBounds = true
        if cell.checkButton.isSelected == true {
            cell.checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        return cell
    }
    
    // 데이터 삭제
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        DeleteToDoList(self: self, editingStyle: editingStyle, tableView: tableView, indexPath: indexPath)
    }
    
    // 투두리스트 선택에 따라
    @objc func checkMarkButtonClicked(sender: UIButton){
        if sender.isSelected{
            sender.isSelected = false
            checkTime = false
            //체크 내용 업데이트
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            sender.isSelected = true
            checkTime = true
            // 체크 내용 업데이트
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        }
        CheckmarkButtonClicked(self: self, checkTime: checkTime, sender: sender)
    }
}

extension DetailClassViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate, UITextViewDelegate {
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        if (self.userType == "teacher") {
            if (self.currentCnt % 8 == 0 && (self.currentCnt == 0 || self.currentCnt == 8)) {
                self.monthlyEvaluationBackgroundView.isHidden = false
            } else {
                self.monthlyEvaluationBackgroundView.isHidden = true
            }
        } else {
            self.monthlyEvaluationBackgroundView.isHidden = true
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
