//
//  ParentDetailEvaluationViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/15.
//

import UIKit
import Firebase
import FirebaseDatabase
import FSCalendar

class ParentDetailEvaluationViewController: UIViewController, FSCalendarDataSource {
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    @IBOutlet weak var monthlyEvaluationTitle: UILabel!
    @IBOutlet weak var monthlyEvaluationTitleBackgroundView: UIView!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    var studentUid: String = ""
    var teacherName: String = ""
    var teacherEmail: String = ""
    var subject: String = ""
    var index: Int = 0
    var month: String = ""
    var studentName: String = ""
    
    let nowDate = Date()
    
    // 캘린더 외관을 꾸미기 위한 메소드
    func calendarColor() {
        calendarView.appearance.weekdayTextColor = .systemGray
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.headerTitleColor =  UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
        calendarView.appearance.eventDefaultColor = .systemPink
        calendarView.appearance.selectionColor = .none
        calendarView.appearance.titleSelectionColor = .black
        calendarView.appearance.todayColor = .systemOrange
        calendarView.appearance.todaySelectionColor = .systemOrange
        calendarView.appearance.borderSelectionColor = .systemOrange
    }
    
    // 캘린더 텍스트 스타일 설정을 위한 메소드
    func calendarText() {
        calendarView.headerHeight = 50
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 25, weight: .bold)
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 15)
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthlyEvaluationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        self.month = dateFormatter.string(from: self.nowDate) + "월"
        
        self.monthlyEvaluationTextView.isEditable = false
        
        getUserInfo()
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        monthlyEvaluationTitleBackgroundView.clipsToBounds = true
        monthlyEvaluationTitleBackgroundView.layer.cornerRadius = 15
        
        monthlyEvaluationTextView.clipsToBounds = true
        monthlyEvaluationTextView.layer.cornerRadius = 15
        
        monthlyEvaluationTitleBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(monthlyEvaluationTitleBackgroundView)
        
        
        monthlyEvaluationTextView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.addSubview(monthlyEvaluationTextView)
        
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    /// nil값 처리
                    let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                    self.db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let studentName = document.data()["name"] as? String ?? ""
                                self.studentName = studentName
                                
                                self.monthlyEvaluationTitle.text = "이번 달 " + studentName + " 학생은..."
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func getUserInfo() {
        self.db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let childPhoneNumber = data!["childPhoneNumber"] as? String ?? ""
                self.db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        self.monthlyEvaluationTextView.text = "아직 이번 달 월말 평가가 등록되지 않았습니다."
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let studentUid = document.data()["uid"] as? String ?? ""
                            
                            self.db.collection("student").document(studentUid).collection("class").whereField("index", isEqualTo: self.index).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let name = document.data()["name"] as? String ?? ""
                                        self.teacherName = name
                                        let email = document.data()["email"] as? String ?? ""
                                        self.teacherEmail = email
                                        let subject = document.data()["subject"] as? String ?? ""
                                        self.subject = subject
                                        self.navigationBarTitle.title = self.studentName + " 학생 " + self.subject + " 월말평가"
                                        
                                        self.db.collection("student").document(studentUid).collection("class").document(name + "(" + email + ") " + self.subject).collection("Evaluation").whereField("month", isEqualTo: self.month).getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print(">>>>> document 에러 : \(err)")
                                            } else {
                                                for document in querySnapshot!.documents {
                                                    let evaluationData = document.data()
                                                    
                                                    let evaluation = evaluationData["evaluation"] as? String ?? "아직 이번 달 월말 평가가 등록되지 않았습니다."
                                                    self.monthlyEvaluationTextView.text = evaluation
                                                    self.monthlyEvaluationTextView.isEditable = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ParentDetailEvaluationViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    // 날짜 선택 시 실행되는 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        guard let teacherEvaluationVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherEvaluationViewController") as? TeacherEvaluationViewController else {
            //아니면 종료
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let selectedMonth = dateFormatter.string(from: date) + "월"
        self.month = selectedMonth
        
        teacherEvaluationVC.modalTransitionStyle = .coverVertical
        teacherEvaluationVC.modalPresentationStyle = .pageSheet
        
        teacherEvaluationVC.teacherName = self.teacherName
        teacherEvaluationVC.teacherEmail = self.teacherEmail
        teacherEvaluationVC.subject = self.subject
        teacherEvaluationVC.month = selectedMonth
        
        self.present(teacherEvaluationVC, animated: true)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentPageDate = calendar.currentPage
        
        let month = Calendar.current.component(.month, from: currentPageDate)
        if (month < 10) {
            self.month = "0\(month)월"
        } else {
            self.month = "\(month)월"
        }
        print ("self.month : \(self.month)")
        getUserInfo()
    }
}
