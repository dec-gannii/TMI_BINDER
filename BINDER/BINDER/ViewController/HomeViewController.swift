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
import BottomHalfModal

class HomeViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var emailVerificationCheckBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var calendarView: FSCalendar!
    
    var id : String = ""
    var pw : String = ""
    var name : String = ""
    var number : Int = 0
    var verified : Bool = false
    var type : String = ""
    
    var ref: DatabaseReference!
    
    func calendarColor() {
        calendarView.backgroundColor = UIColor(red: 242/255, green: 245/255, blue: 249/255, alpha: 1)
        
        calendarView.appearance.weekdayTextColor = .black
        calendarView.appearance.titleWeekendColor = .systemRed
        calendarView.appearance.headerTitleColor = .black
        
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
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20)
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 15)
        
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
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
            logoutBtn.isHidden = true
        } else {
            if (Auth.auth().currentUser?.email != nil) {
                if (type == "teacher") {
                    stateLabel.text = "선생님으로 로그인 성공!\n환영합니다!"
                } else if (type == "student") {
                    stateLabel.text = "학생으로 로그인 성공!\n환영합니다!"
                }
                logoutBtn.isHidden = false
                emailVerificationCheckBtn.isHidden = true
            }
        }
    }
    
    func getInfo(){
        print("number : \(self.number)")
        self.ref.child("users").child("user").child("\(self.number)").observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let number = value?["number"] as? Int ?? 0
            let name = value?["name"] as? String ?? ""
            let id = value?["email"] as? String ?? ""
            let pw = value?["password"] as? String ?? ""
            let type = value?["type"] as? String ?? ""
            
            self.number = number
            self.name = name
            self.id = id
            self.pw = pw
        })
    }
    
    func verifiedCheck() {
        print("pw: " + self.pw)
        getInfo()
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
    
    @IBAction func LogOutBtnClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
        
        if Auth.auth().currentUser != nil {
            // Show logout page
            let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
            signinVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            signinVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(signinVC!, animated: true, completion: nil)
        } else {
            // Show login page
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
            loginVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            loginVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(loginVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func CheckVerification(_ sender: Any) {
        verifiedCheck()
        if (verified == false) {
            stateLabel.text = "이메일 인증이 진행중입니다."
            emailVerificationCheckBtn.isHidden = false
            logoutBtn.isHidden = true
        } else {
            if (Auth.auth().currentUser?.email != nil) {
                if (type == "teacher") {
                    stateLabel.text = "선생님으로 인증 성공!\n환영합니다!"
                } else if (type == "student") {
                    stateLabel.text = "학생으로 인증 성공!\n환영합니다!"
                }
                logoutBtn.isHidden = false
                emailVerificationCheckBtn.isHidden = true
            }
        }
    }
    
}

extension HomeViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        guard let addScehduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        addScehduleVC.date = dateFormatter.string(from: date)
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        self.present(addScehduleVC, animated: true, completion: nil)
    }
}

extension HomeViewController: FSCalendarDataSource {
    
}
