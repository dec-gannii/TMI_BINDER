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

/// home view controller
public class HomeViewController: UIViewController, FSCalendarDataSource {
    // 변수 선언
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var HomeStudentIconLabel: UILabel!
    @IBOutlet weak var HomeStudentIconSecondLabel: UILabel!
    @IBOutlet weak var HomeStudentIconThirdLabel: UILabel!
    @IBOutlet weak var HomeStudentScrollView: UIScrollView!
    @IBOutlet weak var firstLinkBtn: UIButton!
    @IBOutlet weak var secondLinkBtn: UIButton!
    @IBOutlet weak var thirdLinkBtn: UIButton!
    
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var linkTypeLabel: UILabel!
    @IBOutlet weak var eventCountTxt: UILabel!
    @IBOutlet weak var homeStudentClassTxt: UILabel!
    @IBOutlet weak var homeStudentClassTxt2: UILabel!
    @IBOutlet weak var homeStudentClassTxt3: UILabel!
    
    var classItems: [String] = [] // 수업 변수 배열
    var events: [Date] = [] // 이벤트가 있는 날짜 배열
    var days: [Date] = [] // 선택된 월의 날짜들
    var id : String = ""
    var pw : String = ""
    var name : String = ""
    var number : Int = 1
    var verified : Bool = false
    var type : String = ""
    var date : String!
    
    var ref: DatabaseReference!
    var calenderDesign = CalendarDesign()
    var homeDB = HomeVCDBFunctions()
    
    /// calendar custom
    private var currentPage: Date?
    private lazy var today: Date = { return Date() }()
    
    @IBAction func prevBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: true) }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: false) }
    
    public func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.days.removeAll()
        self.events.removeAll()
        
        self.monthLabel.text = calenderDesign.dateFormatter.string(from: calendar.currentPage)
        let date = calenderDesign.dateFormatter.date(from: self.monthLabel.text!)
        
        days = setUpDays(date!)
        
        homeDB.GetTeacherEvents(events: self.events, days: self.days, self: self)
        homeDB.GetStudentEvents(events: self.events, days: self.days, self: self)
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    /// Load View
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.calendarView.reloadData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTeacherInfo()
        getStudentInfo()
        self.calendarView.reloadData()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeStudentClassTxt3.isHidden = true
        self.homeStudentClassTxt2.isHidden = true
        self.homeStudentClassTxt.isHidden = true

        days = setUpDays(self.today)
        
        calendarView.delegate = self
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner)
        
        eventCountTxt.clipsToBounds = true
        eventCountTxt.layer.cornerRadius = 10
        eventCountTxt.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner)
        
        homeStudentClassTxt.clipsToBounds = true
        homeStudentClassTxt.layer.cornerRadius = 5
        homeStudentClassTxt.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner)
        
        homeStudentClassTxt2.clipsToBounds = true
        homeStudentClassTxt2.layer.cornerRadius = 5
        homeStudentClassTxt2.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner)
        
        homeStudentClassTxt3.clipsToBounds = true
        homeStudentClassTxt3.layer.cornerRadius = 5
        homeStudentClassTxt3.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner)
        
        calendarColor(view: calendarView, design: calenderDesign)
        self.calendarEvent()
        calenderDesign.setCalendar(calendarView: self.calendarView, monthLabel: self.monthLabel)
    }
    
    /// 내 수업 가져오기 : 선생님
    func setTeacherMyClasses() {
        
        // 데이터베이스에서 학생 리스트 가져오기, 초기화
        self.HomeStudentIconLabel.text = ""
        self.HomeStudentIconSecondLabel.text = ""
        self.HomeStudentIconThirdLabel.text = ""
        
        // 만약 학생이 없다면 버튼과 레이블을 숨기기
        self.firstLinkBtn.isHidden = true
        self.HomeStudentIconLabel.isHidden = true
        self.secondLinkBtn.isHidden = true
        self.HomeStudentIconSecondLabel.isHidden = true
        self.thirdLinkBtn.isHidden = true
        self.HomeStudentIconThirdLabel.isHidden = true
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
            "fcmToken": Messaging.messaging().fcmToken
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        
        homeDB.GetTeacherMyClass(self: self)
    }
    
    /// 내 수업 가져오기 : 학생
    func setStudentMyClasses() {
        
        // 데이터베이스에서 학생 리스트 가져오기, 초기화
        self.HomeStudentIconLabel.text = ""
        self.HomeStudentIconSecondLabel.text = ""
        self.HomeStudentIconThirdLabel.text = ""
        
        // 만약 학생이 없다면 버튼과 레이블을 숨기기
        self.firstLinkBtn.isHidden = true
        self.HomeStudentIconLabel.isHidden = true
        self.secondLinkBtn.isHidden = true
        self.HomeStudentIconSecondLabel.isHidden = true
        self.thirdLinkBtn.isHidden = true
        self.HomeStudentIconThirdLabel.isHidden = true
        
        db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
            "fcmToken": Messaging.messaging().fcmToken
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        
        homeDB.GetStudentMyClass(self: self)
    }
    
    /// linked button clicked
    @IBAction func ButtonClicked(_ sender: Any) {
        guard let detailClassVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassDetailViewController") as? MyClassDetailViewController else { return }
        
        homeDB.GetLinkButtonInfos(sender: sender as! UIButton, firstLabel: HomeStudentIconLabel, secondLabel: HomeStudentIconSecondLabel, thirdLabel: HomeStudentIconThirdLabel, detailVC: detailClassVC, self: self)
    }
    
    /// setting informations
    func getTeacherInfo(){
        homeDB.GetTeacherInfo(days: self.days, homeStudentScrollView: self.HomeStudentScrollView, stateLabel: self.stateLabel, self: self)
        setTeacherMyClasses()
    }
    
    func getStudentInfo(){
        homeDB.GetStudentInfo(days: self.days, homeStudentScrollView: self.HomeStudentScrollView, stateLabel: self.stateLabel, self: self)
        setStudentMyClasses()
    }
}


extension HomeViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate, FSCalendarDelegateAppearance {
    // 날짜 선택 시 실행되는 메소드
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let datestr = dateFormatter.string(from: date)
        // 일정 리스트 뷰 보여주기
        guard let scheduleListVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleListViewController") as? ScheduleListViewController else { return }
        // 데이터베이스의 Count document에서 count 정보를 받아서 전달
        homeDB.ShowScheduleList(date: datestr, scheduleListVC: scheduleListVC, self: self)
    }
    
    //이벤트 표시 개수
    public func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if sharedEvents.contains(date) { return 1 }
        else { return 0 }
    }
    
    public func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if sharedEvents.contains(date) { return UIColor(red: 1, green: 104, blue: 255, alpha: 1) }
        else { return nil }
    }
}

