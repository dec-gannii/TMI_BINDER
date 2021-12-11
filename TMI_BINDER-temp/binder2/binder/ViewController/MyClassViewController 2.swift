//
//  MyClassViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/26.
//

import UIKit
import Firebase
import FSCalendar

class MyClassViewController: UIViewController {
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var evaluationView: UIView!
    @IBOutlet weak var progressTextView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var testScoreTextField: UITextField!
    @IBOutlet weak var evaluationMemoTextView: UITextView!
    @IBOutlet weak var evaluationOKBtn: UIButton!
    @IBOutlet weak var homeworkScoreTextField: UITextField!
    @IBOutlet weak var classScoreTextField: UITextField!
    
    
    var date: String!
    var userName: String!
    
    func calendarColor() {
        calendarView.backgroundColor = UIColor(red: 242/255, green: 245/255, blue: 249/255, alpha: 1)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        
        let db = Firestore.firestore()
        let docRef = db.collection("Evaluation").document(Auth.auth().currentUser!.uid).collection("\(date)").document("DailyEvaluation")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.date = data?["EvaluationDate"] as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
        
        evaluationView.isHidden = true
        evaluationOKBtn.isHidden = true
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        self.progressTextView.layer.borderWidth = 1.0
        self.progressTextView.layer.borderColor = UIColor.systemGray6.cgColor
        
        self.evaluationMemoTextView.layer.borderWidth = 1.0
        self.evaluationMemoTextView.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    func getUserInfo() {
        let db = Firestore.firestore()
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["Name"] as? String ?? ""
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                self.questionLabel.text = "오늘 " + self.userName! + " 학생의 수업 참여는 어땠나요?";
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func OKButtonClicked(_ sender: Any) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        db.collection("Evaluation").document(Auth.auth().currentUser!.uid).collection("\(self.date!)").document("DailyEvaluation").setData([
            "Progress": progressTextView.text!,
            "TestScore": Int(testScoreTextField.text!),
            "HomeworkCompletion": Int(homeworkScoreTextField.text!),
            "ClassAttitude": Int(classScoreTextField.text!),
            "EvaluationMemo": evaluationMemoTextView.text!,
            "EvaluationDate": self.date
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
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
extension MyClassViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        let selectedDate = date
        let nowDate = Date()
        
        let distanceDay = Calendar.current.dateComponents([.day], from: selectedDate, to: nowDate).day
        
        if (!(distanceDay! <= 0)) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            let dateStr = dateFormatter.string(from: selectedDate)
            self.date = dateStr
            
            let db = Firestore.firestore()
            let docRef = db.collection("Evaluation").document(Auth.auth().currentUser!.uid).collection(dateStr).document("DailyEvaluation")
            
            if (docRef != nil){
                evaluationView.isHidden = false
                evaluationOKBtn.isHidden = false
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
                        self.progressTextView.text = ""
                        self.testScoreTextField.text = ""
                        self.evaluationMemoTextView.text = ""
                        self.homeworkScoreTextField.text = ""
                        self.classScoreTextField.text = ""
                    }
                }
            }
        } else {
            evaluationView.isHidden = true
            evaluationOKBtn.isHidden = true
        }
    }
}

extension MyClassViewController: FSCalendarDataSource {
    
}
