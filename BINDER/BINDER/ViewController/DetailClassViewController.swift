//
//  MyClassViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/26.
//

import UIKit
import Firebase
import FSCalendar

// 수업 관리를 위한 디테일 클래스 뷰 컨트롤러
class DetailClassViewController: UIViewController {
    
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
    
    var date: String!
    var userName: String!
    var userIndex: Int!
    var keyHeight: CGFloat?
    var userEmail: String!
    var userSubject: String!
    
    let db = Firestore.firestore()
    
    // 캘린더 외관을 꾸미기 위한 메소드
    func calendarColor() {
        calendarView.scope = .week
        
        calendarView.appearance.weekdayTextColor = .systemGray
        calendarView.appearance.titleWeekendColor = .systemGray
        calendarView.appearance.headerTitleColor = .black
        
        calendarView.appearance.eventDefaultColor = .systemPink
        calendarView.appearance.selectionColor = .systemGray3
        calendarView.appearance.titleSelectionColor = .black
        calendarView.appearance.todayColor = .systemOrange
        calendarView.appearance.titleTodayColor = .black
        calendarView.appearance.todaySelectionColor = .systemOrange
    }
    
    // 캘린더 텍스트 스타일 설정을 위한 메소드
    func calendarText() {
        calendarView.headerHeight = 50
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 15)
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 13)
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 13)
        
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        
        evaluationView.layer.cornerRadius = 10
        
        evaluationView.isHidden = true
        evaluationOKBtn.isHidden = true
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        self.progressTextView.layer.borderWidth = 1.0
        self.progressTextView.layer.borderColor = UIColor.systemGray6.cgColor
        
        self.evaluationMemoTextView.layer.borderWidth = 1.0
        self.evaluationMemoTextView.layer.borderColor = UIColor.systemGray6.cgColor
        
        if (self.userName != nil) {
            self.classNavigationBar.topItem!.title = self.userName + " 학생"
            self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
        }
        print(self.userIndex)
    }
    
    // 그래프를 보여주도록 하는 메소드
    @IBAction func ShowGraph(_ sender: Any) {
        guard let graphVC = self.storyboard?.instantiateViewController(withIdentifier: "GraphViewController") as? GraphViewController else { return }
        
        graphVC.modalPresentationStyle = .fullScreen
        graphVC.modalTransitionStyle = .crossDissolve
        // 학생의 이름 데이터 넘겨주기
        graphVC.userName = self.userName
        graphVC.userSubject = self.userSubject
        graphVC.userEmail = self.userEmail
        
        self.present(graphVC, animated: true, completion: nil)
    }
    
    // 사용자의 정보를 가져오도록 하는 메소드
    func getUserInfo() {
        // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: self.userIndex)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            
                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                            // 네비게이션 바의 이름도 설정해주기
                            let name = document.data()["name"] as? String ?? ""
                            self.userName = name
                            self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
                            self.userEmail = document.data()["email"] as? String ?? ""
                            self.userSubject = document.data()["subject"] as? String ?? ""
                            
                            self.classNavigationBar.topItem!.title = self.userName + " 학생"
                        }
                    }
                }
            }
    }
    
    // 뒤로가기 버튼 클릭 시 실행되는 메소드
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    // 평가 저장하기 버튼 클릭 시 실행되는 메소드
    @IBAction func OKButtonClicked(_ sender: Any) {
        // 경로는 각 학생의 class의 Evaluation
        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)").setData([
            "Progress": progressTextView.text!,
            "TestScore": Int(testScoreTextField.text!) ?? 0,
            "HomeworkCompletion": Int(homeworkScoreTextField.text!) ?? 0,
            "ClassAttitude": Int(classScoreTextField.text!) ?? 0,
            "EvaluationMemo": evaluationMemoTextView.text!,
            "EvaluationDate": self.date ?? ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
            // 저장 이후에는 다시 안 보이도록 함
            self.evaluationView.isHidden = true
            self.evaluationOKBtn.isHidden = true
            self.progressTextView.text = ""
            self.testScoreTextField.text = ""
            self.evaluationMemoTextView.text = ""
        }
        evaluationView.isHidden = true
        evaluationOKBtn.isHidden = true
    }
}

extension DetailClassViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    // 날짜를 하나 선택 하면 실행되는 메소드
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        let selectedDate = date
        let nowDate = Date()
        
        // 수업을 하지 않은 미래의 수업에 대해서는 평가를 할 수 없도록 하기 위해서 오늘 날짜와 선택한 날짜 비교
        let distanceDay = Calendar.current.dateComponents([.day], from: selectedDate, to: nowDate).day
        
        // 차이가 0보다 작거나 같으면
        if (!(distanceDay! <= 0)) {
            // 평가 입력 뷰를 숨김 해제
            evaluationView.isHidden = false
            evaluationOKBtn.isHidden = false
            
            // 날짜 받아와서 변수에 저장
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            let dateStr = dateFormatter.string(from: selectedDate)
            self.date = dateStr
            
            // 데이터베이스 경로
            let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)")
            
            // 데이터를 받아와서 각각의 값에 따라 textfield 값 설정 (만약 없다면 공백 설정, 있다면 그 값 불러옴)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.date = data?["EvaluationDate"] as? String ?? ""
                    
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let homeworkCompletion = data?["HomeworkCompletion"] as? Int ?? 0
                    if (homeworkCompletion == 0) {
                        self.homeworkScoreTextField.text = ""
                    } else {
                        self.homeworkScoreTextField.text = "\(homeworkCompletion)"
                    }
                    
                    let classAttitude = data?["ClassAttitude"] as? Int ?? 0
                    if (classAttitude == 0) {
                        self.classScoreTextField.text = ""
                    } else {
                        self.classScoreTextField.text = "\(classAttitude)"
                    }
                    
                    let progressText = data?["Progress"] as? String ?? ""
                    self.progressTextView.text = progressText
                    
                    let evaluationMemo = data?["EvaluationMemo"] as? String ?? ""
                    self.evaluationMemoTextView.text = evaluationMemo
                    
                    let testScore = data?["TestScore"] as? Int ?? 0
                    if (testScore == 0) {
                        self.testScoreTextField.text = ""
                    } else {
                        self.testScoreTextField.text = "\(testScore)"
                    }
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                    // 값 다시 공백 설정
                    self.progressTextView.text = ""
                    self.testScoreTextField.text = ""
                    self.evaluationMemoTextView.text = ""
                    self.homeworkScoreTextField.text = ""
                    self.classScoreTextField.text = ""
                }
            }
        } else {
            // 그대로 숨김 유지
            evaluationView.isHidden = true
            evaluationOKBtn.isHidden = true
        }
    }
}

extension DetailClassViewController: FSCalendarDataSource {
    
}
