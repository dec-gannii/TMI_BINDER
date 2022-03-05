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

// 홈 뷰 컨트롤러
class HomeViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var emailVerificationCheckBtn: UIButton!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var HomeStudentIconLabel: UILabel!
    @IBOutlet weak var HomeStudentIconSecondLabel: UILabel!
    @IBOutlet weak var HomeStudentIconThirdLabel: UILabel!
    @IBOutlet weak var HomeStudentScrollView: UIScrollView!
    @IBOutlet weak var firstLinkBtn: UIButton!
    @IBOutlet weak var secondLinkBtn: UIButton!
    @IBOutlet weak var thirdLinkBtn: UIButton!
    
    /// 수업 변수 배열
    var classItems: [String] = []
    
    var id : String = ""
    var pw : String = ""
    var name : String = ""
    var number : Int = 1
    var verified : Bool = false
    var type : String = ""
    
    var date : String!
    
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    
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
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        calendarView.delegate = self
        verifiedCheck() // 인증된 이메일인지 체크하는 메소드
        
        getTeacherInfo()
        getStudentInfo()
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        // 인증되지 않은 계정이라면
        if (!verified) {
            stateLabel.text = "작성한 이메일로 인증을 진행해주세요."
            emailVerificationCheckBtn.isHidden = false
        } else {
            // 인증되었고,
            if (self.type == "teacher") { // 선생님 계정이라면
                if (Auth.auth().currentUser?.email != nil) {
                    emailVerificationCheckBtn.isHidden = true
                    HomeStudentScrollView.isHidden = true
                }
            } else {
                // 학생 계정이라면
                if (Auth.auth().currentUser?.email != nil) {
                    emailVerificationCheckBtn.isHidden = true
                }
            }
        }
    }
    
    // 내 수업 가져오기 : 선생님
    func setTeacherMyClasses() {
        // 데이터베이스에서 학생 리스트 가져오기, 초기화
        self.HomeStudentIconLabel.text = ""
        self.HomeStudentIconSecondLabel.text = ""
        self.HomeStudentIconThirdLabel.text = ""
        
        let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class")
        
        // index가 0, 1, 2인 세 명의 학생 정보 가져오기
        docRef.whereField("index", isEqualTo: 0).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    self.HomeStudentIconLabel.text = document.data()["name"] as? String ?? ""
                    self.firstLinkBtn.isHidden = false
                    self.HomeStudentIconLabel.isHidden = false
                }
            }
        }
        
        docRef.whereField("index", isEqualTo: 1).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    self.HomeStudentIconSecondLabel.text = document.data()["name"] as? String ?? ""
                    self.secondLinkBtn.isHidden = false
                    self.HomeStudentIconSecondLabel.isHidden = false
                }
            }
        }
        
        docRef.whereField("index", isEqualTo: 2).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    self.HomeStudentIconThirdLabel.text = document.data()["name"] as? String ?? ""
                    self.thirdLinkBtn.isHidden = false
                    self.HomeStudentIconThirdLabel.isHidden = false
                }
            }
        }
        
        // 만약 학생이 없다면 버튼과 레이블을 숨기기
        if (self.HomeStudentIconLabel.text == "" || self.HomeStudentIconLabel.text == "Name Label") {
            self.firstLinkBtn.isHidden = true
            self.HomeStudentIconLabel.isHidden = true
        }
        
        if (self.HomeStudentIconSecondLabel.text == "" || self.HomeStudentIconSecondLabel.text == "Name Label") {
            self.secondLinkBtn.isHidden = true
            self.HomeStudentIconSecondLabel.isHidden = true
        }
        
        if (self.HomeStudentIconThirdLabel.text == "" || self.HomeStudentIconThirdLabel.text == "Name Label") {
            self.thirdLinkBtn.isHidden = true
            self.HomeStudentIconThirdLabel.isHidden = true
        }
    }
    
    
    func setStudentMyClasses() {
        // 데이터베이스에서 학생 리스트 가져오기, 초기화
        self.HomeStudentIconLabel.text = ""
        self.HomeStudentIconSecondLabel.text = ""
        self.HomeStudentIconThirdLabel.text = ""
        
        let docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class")
        
        // index가 0, 1, 2인 세 명의 학생 정보 가져오기
        docRef.whereField("index", isEqualTo: 0).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    self.HomeStudentIconLabel.text = document.data()["name"] as? String ?? ""
                    self.firstLinkBtn.isHidden = false
                    self.HomeStudentIconLabel.isHidden = false
                }
            }
        }
        
        docRef.whereField("index", isEqualTo: 1).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    self.HomeStudentIconSecondLabel.text = document.data()["name"] as? String ?? ""
                    self.secondLinkBtn.isHidden = false
                    self.HomeStudentIconSecondLabel.isHidden = false
                }
            }
        }
        
        docRef.whereField("index", isEqualTo: 2).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    self.HomeStudentIconThirdLabel.text = document.data()["name"] as? String ?? ""
                    self.thirdLinkBtn.isHidden = false
                    self.HomeStudentIconThirdLabel.isHidden = false
                }
            }
        }
        
        // 만약 학생이 없다면 버튼과 레이블을 숨기기
        if (self.HomeStudentIconLabel.text == "" || self.HomeStudentIconLabel.text == "Name Label") {
            self.firstLinkBtn.isHidden = true
            self.HomeStudentIconLabel.isHidden = true
        }
        
        if (self.HomeStudentIconSecondLabel.text == "" || self.HomeStudentIconSecondLabel.text == "Name Label") {
            self.secondLinkBtn.isHidden = true
            self.HomeStudentIconSecondLabel.isHidden = true
        }
        
        if (self.HomeStudentIconThirdLabel.text == "" || self.HomeStudentIconThirdLabel.text == "Name Label") {
            self.thirdLinkBtn.isHidden = true
            self.HomeStudentIconThirdLabel.isHidden = true
        }
    }
    
    
    @IBAction func ButtonClicked(_ sender: Any) {
        // 데이터베이스 경로
        var email = ""
        var subject = ""
        var btnIndex = 0
        var type = self.type
        
        if (self.type == "teacher") {
            
            type = "teacher"
            var docRef = self.db.collection(type).document(Auth.auth().currentUser!.uid).collection("class")
            
            guard let detailClassVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController") as? DetailClassViewController else { return }
            
            // 설정해둔 버튼의 태그에 따라서 레이블의 이름을 가지고 비교 후 학생 관리 페이지로 넘어가기
            if ((sender as AnyObject).tag == 0) {
                if let name = self.HomeStudentIconLabel.text {
                    docRef.whereField("name", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                btnIndex = document.data()["index"] as? Int ?? 0
                                email = document.data()["email"] as? String ?? ""
                                subject = document.data()["subject"] as? String ?? ""
                            }
                            // 학생의 이름 데이터 넘겨주기
                            detailClassVC.userName = name
                            detailClassVC.userSubject = subject
                            detailClassVC.userEmail = email
                            detailClassVC.userIndex = btnIndex
                            detailClassVC.userType = type
                            
                            detailClassVC.modalPresentationStyle = .fullScreen
                            detailClassVC.modalTransitionStyle = .crossDissolve
                            
                            self.present(detailClassVC, animated: true, completion: nil)
                        }
                    }
                }
            } else if ((sender as AnyObject).tag == 1) {
                if let name = self.HomeStudentIconSecondLabel.text {
                    docRef.whereField("name", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                btnIndex = document.data()["index"] as? Int ?? 0
                                email = document.data()["email"] as? String ?? ""
                                subject = document.data()["subject"] as? String ?? ""
                            }
                            // 학생의 이름 데이터 넘겨주기
                            detailClassVC.userName = name
                            detailClassVC.userSubject = subject
                            detailClassVC.userEmail = email
                            detailClassVC.userIndex = btnIndex
                            detailClassVC.userType = type
                            
                            detailClassVC.modalPresentationStyle = .fullScreen
                            detailClassVC.modalTransitionStyle = .crossDissolve
                            
                            self.present(detailClassVC, animated: true, completion: nil)
                        }
                    }
                }
            } else if ((sender as AnyObject).tag == 2) {
                if let name = self.HomeStudentIconThirdLabel.text {
                    docRef.whereField("name", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                btnIndex = document.data()["index"] as? Int ?? 0
                                email = document.data()["email"] as? String ?? ""
                                subject = document.data()["subject"] as? String ?? ""
                            }
                            // 학생의 이름 데이터 넘겨주기
                            detailClassVC.userName = name
                            detailClassVC.userSubject = subject
                            detailClassVC.userEmail = email
                            detailClassVC.userIndex = btnIndex
                            detailClassVC.userType = type
                            
                            detailClassVC.modalPresentationStyle = .fullScreen
                            detailClassVC.modalTransitionStyle = .crossDissolve
                            
                            self.present(detailClassVC, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            
            type = "student"
            var docRef = self.db.collection(type).document(Auth.auth().currentUser!.uid).collection("class")
            
            guard let detailClassVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController") as? DetailClassViewController else { return }
            
            // 설정해둔 버튼의 태그에 따라서 레이블의 이름을 가지고 비교 후 학생 관리 페이지로 넘어가기
            if ((sender as AnyObject).tag == 0) {
                if let name = self.HomeStudentIconLabel.text {
                    docRef.whereField("name", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                btnIndex = document.data()["index"] as? Int ?? 0
                                email = document.data()["email"] as? String ?? ""
                                subject = document.data()["subject"] as? String ?? ""
                            }
                            // 선생님의 이름 데이터 넘겨주기
                            detailClassVC.userName = name
                            detailClassVC.userSubject = subject
                            detailClassVC.userEmail = email
                            detailClassVC.userIndex = btnIndex
                            detailClassVC.userType = type
                            
                            detailClassVC.modalPresentationStyle = .fullScreen
                            detailClassVC.modalTransitionStyle = .crossDissolve
                            
                            self.present(detailClassVC, animated: true, completion: nil)
                        }
                    }
                }
            } else if ((sender as AnyObject).tag == 1) {
                if let name = self.HomeStudentIconSecondLabel.text {
                    docRef.whereField("name", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                btnIndex = document.data()["index"] as? Int ?? 0
                                email = document.data()["email"] as? String ?? ""
                                subject = document.data()["subject"] as? String ?? ""
                            }
                            // 학생의 이름 데이터 넘겨주기
                            detailClassVC.userName = name
                            detailClassVC.userSubject = subject
                            detailClassVC.userEmail = email
                            detailClassVC.userIndex = btnIndex
                            detailClassVC.userType = type
                            
                            detailClassVC.modalPresentationStyle = .fullScreen
                            detailClassVC.modalTransitionStyle = .crossDissolve
                            
                            self.present(detailClassVC, animated: true, completion: nil)
                        }
                    }
                }
            } else if ((sender as AnyObject).tag == 2) {
                if let name = self.HomeStudentIconThirdLabel.text {
                    docRef.whereField("name", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                btnIndex = document.data()["index"] as? Int ?? 0
                                email = document.data()["email"] as? String ?? ""
                                subject = document.data()["subject"] as? String ?? ""
                            }
                            // 학생의 이름 데이터 넘겨주기
                            detailClassVC.userName = name
                            detailClassVC.userSubject = subject
                            detailClassVC.userEmail = email
                            detailClassVC.userIndex = btnIndex
                            detailClassVC.userType = type
                            
                            detailClassVC.modalPresentationStyle = .fullScreen
                            detailClassVC.modalTransitionStyle = .crossDissolve
                            
                            self.present(detailClassVC, animated: true, completion: nil)
                        }
                    }
                }
            }
            
        }
        
    }
    
    func getTeacherInfo(){
        // 데이터베이스 경로
        let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["name"] as? String ?? ""
                self.stateLabel.text = self.name + " 선생님 환영합니다!"
                if (Auth.auth().currentUser?.email == (data?["email"] as! String)) {
                    self.type = "teacher"
                } else {
                    self.type = data?["type"] as? String ?? ""
                }
                self.id = data?["email"] as? String ?? ""
                self.pw = data?["password"] as? String ?? ""
                self.HomeStudentScrollView.isHidden = false
            } else {
                print("Document does not exist")
            }
        }
        
        setTeacherMyClasses()
    }
    
    func getStudentInfo(){
        // 데이터베이스 경로
        let docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid)
        
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["name"] as? String ?? ""
                self.stateLabel.text = self.name + " 학생 환영합니다!"
                self.id = data?["email"] as? String ?? ""
                self.pw = data?["password"] as? String ?? ""
                if (Auth.auth().currentUser?.email == (data?["email"] as! String)) {
                    self.type = "student"
                } else {
                    self.type = data?["type"] as? String ?? ""
                }
                self.HomeStudentScrollView.isHidden = false
            } else {
                print("Document does not exist")
            }
        }
        
        setStudentMyClasses()
    }
    
    func verifiedCheck() {
        getStudentInfo() // 학생 정보 받아오기
        getTeacherInfo() // 선생님 정보 받아오기
        // id와 pw 변수에 저장된 걸로 로그인 진행
        Auth.auth().signIn(withEmail: id, password: pw) { result, error in
            let check = Auth.auth().currentUser?.isEmailVerified // 이메일 인증 여부
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if (check == false) {
                    self.verified = false // 인증 안 되었으면 false 설정
                } else {
                    self.verified = true // 인증 되었으면 true 설정
                }
            }
        }
    }
    // 인증 확인 버튼 클릭시 실행되는 메소드
    @IBAction func CheckVerification(_ sender: Any) {
        verifiedCheck() // 이메일 인증 여부 확인 메소드 실행
        if (verified == false) { // false면,
            stateLabel.text = "이메일 인증이 진행중입니다."
            emailVerificationCheckBtn.isHidden = false
        } else { // true면,
            if (Auth.auth().currentUser?.email != nil) {
                if (type == "teacher") { // 선생님 계정이면
                    stateLabel.text = name + " 선생님 환영합니다!"
                } else if (type == "student") { // 학생 계정이면
                    stateLabel.text = name + " 학생 환영합니다!"
                }
                calendarView.isHidden = false // 캘린더 뷰 숨겨둔 거 보여주기
                emailVerificationCheckBtn.isHidden = true // 이메일 인증 확인 버튼 숨기기
                if (self.type == "teacher") { // 선생님 계정이라면
                    if (Auth.auth().currentUser?.email != nil) {
                        emailVerificationCheckBtn.isHidden = true
                        HomeStudentScrollView.isHidden = true
                    }
                } else {
                    // 학생 계정이라면
                    if (Auth.auth().currentUser?.email != nil) {
                        calendarView.isHidden = false
                        emailVerificationCheckBtn.isHidden = true
                    }
                }
            }
        }
    }
}

extension HomeViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    // 날짜 선택 시 실행되는 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        // 일정 리스트 뷰 보여주기
        guard let scheduleListVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleListViewController") as? ScheduleListViewController else { return }
        // 데이터베이스의 Count document에서 count 정보를 받아서 전달
        //        self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(dateFormatter.string(from: date))
        self.db.collection(self.type).document(Auth.auth().currentUser!.uid).collection("schedule").document(dateFormatter.string(from: date)).collection("scheduleList").document("Count").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            scheduleListVC.count = data["count"] as! Int
        }
        
        // 날짜 데이터 넘겨주기
        scheduleListVC.date = dateFormatter.string(from: date)
        scheduleListVC.type = self.type
        scheduleListVC.modalPresentationStyle = .fullScreen
        self.present(scheduleListVC, animated: true, completion: nil)
    }
    
}
extension HomeViewController: FSCalendarDataSource {
}
