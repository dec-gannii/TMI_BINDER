//
//  HomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FSCalendar

class HomeViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var emailVerificationCheckBtn: UIButton!
    @IBOutlet weak var calendarView: FSCalendar!
    
    var id : String = ""
    var pw : String = ""
    var name : String = ""
    var number : Int = 1
    var verified : Bool = false
    var type : String = ""
    
    var events = [Date]()
    var date : String!
    
    var ref: DatabaseReference!
    
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
    
    func calendarText() {
        calendarView.headerHeight = 50
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 25, weight: .heavy)
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 15)
        
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    func setUpEvents(_ eventDate: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd EEEE"
        let event = formatter.date(from: eventDate)
        let sampledate = formatter.date(from: eventDate)
        events = [event!, sampledate!]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        calendarView.delegate = self
        verifiedCheck()
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        if (!verified) {
            stateLabel.text = "작성한 이메일로 인증을 진행해주세요."
            emailVerificationCheckBtn.isHidden = false
            calendarView.isHidden = true
        } else {
            let db = Firestore.firestore()
            var docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
            if (docRef != nil) {
                getTeacherInfo()
                if (Auth.auth().currentUser?.email != nil) {
                    calendarView.isHidden = false
                    emailVerificationCheckBtn.isHidden = true
                }
            } else {
                getStudentInfo()
                if (Auth.auth().currentUser?.email != nil) {
                    calendarView.isHidden = false
                    emailVerificationCheckBtn.isHidden = true
                }
            }
        }
    }
    
    func getTeacherInfo(){
        let db = Firestore.firestore()
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["Name"] as? String ?? ""
                self.stateLabel.text = self.name + " 선생님 환영합니다!"
                self.id = data?["Email"] as? String ?? ""
                self.pw = data?["Password"] as? String ?? ""
                self.type = data?["Type"] as? String ?? ""
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getStudentInfo(){
        let db = Firestore.firestore()
        let docRef = db.collection("student").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["Name"] as? String ?? ""
                self.stateLabel.text = self.name + " 학생 환영합니다!"
                self.id = data?["Email"] as? String ?? ""
                self.pw = data?["Password"] as? String ?? ""
                self.type = data?["Type"] as? String ?? ""
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func verifiedCheck() {
        print("pw: " + self.pw)
        getStudentInfo()
        getTeacherInfo()
        Auth.auth().signIn(withEmail: id, password: pw) { result, error in
            var check = Auth.auth().currentUser?.isEmailVerified
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if (check == false) {
                    self.verified = false
                } else {
                    self.verified = true
                }
            }
        }
        
    }
    
    @IBAction func CheckVerification(_ sender: Any) {
        verifiedCheck()
        if (verified == false) {
            stateLabel.text = "이메일 인증이 진행중입니다."
            emailVerificationCheckBtn.isHidden = false
        } else {
            if (Auth.auth().currentUser?.email != nil) {
                if (type == "teacher") {
                    stateLabel.text = name + " 선생님 환영합니다!"
                } else if (type == "student") {
                    stateLabel.text = name + " 학생 환영합니다!"
                }
                calendarView.isHidden = false
                emailVerificationCheckBtn.isHidden = true
            }
        }
    }
    
}

extension HomeViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        guard let scheduleListVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleListViewController") as? ScheduleListViewController else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        self.date = dateFormatter.string(from: date)
        setUpEvents(dateFormatter.string(from: date))
        scheduleListVC.date = dateFormatter.string(from: date)
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        self.present(scheduleListVC, animated: true, completion: nil)
    }
    
}

extension HomeViewController: FSCalendarDataSource {
    
}
