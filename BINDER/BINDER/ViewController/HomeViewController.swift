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
public class HomeViewController: UIViewController {
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
    let db = Firestore.firestore()
    var calenderDesign = CalendarDesign()
    
    /// calendar custom
    private var currentPage: Date?
    private lazy var today: Date = { return Date() }()
    
    @IBAction func prevBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: true) }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: false) }
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 MM월"
        return df
    }()
    
    func setCalendar() {
        calendarView.delegate = self
        calendarView.headerHeight = 0
        calendarView.scope = .month
        monthLabel.text = self.dateFormatter.string(from: calendarView.currentPage)
    }
    
    public func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.days.removeAll()
        self.events.removeAll()
        
        self.monthLabel.text = self.dateFormatter.string(from: calendar.currentPage)
        let date = self.dateFormatter.date(from: self.monthLabel.text!)
        
        self.setUpDays(date!)
        
        GetTeacherEvents(events: self.events, days: self.days, self: self)
        GetStudentEvents(events: self.events, days: self.days, self: self)
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    // 캘린더 외관을 꾸미기 위한 메소드
    func calendarColor() {
        calendarView.appearance.weekdayTextColor = .systemGray
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.headerTitleColor =  calenderDesign.calendarColor
        calendarView.appearance.eventDefaultColor = UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        calendarView.appearance.eventSelectionColor = UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        
        calendarView.appearance.titleSelectionColor = calenderDesign.calendarColor
        calendarView.appearance.borderSelectionColor = UIColor(red: 205, green: 231, blue: 252, alpha: 1)
        calendarView.appearance.titleTodayColor = UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        calendarView.appearance.todaySelectionColor = UIColor(red: 205, green: 231, blue: 252, alpha: 1)
        calendarView.appearance.selectionColor = .none
        calendarView.appearance.todayColor = UIColor(red: 205, green: 231, blue: 252, alpha: 1)
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    func setUpDays(_ date: Date) {
        let nowDate = date // 오늘 날짜
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        
        formatter.dateFormat = "M"
        let currentDate = formatter.string(from: nowDate)
        
        formatter.dateFormat = "yyyy"
        let currentYear = formatter.string(from: nowDate)
        
        formatter.dateFormat = "MM"
        let currentMonth = formatter.string(from: nowDate)
        
        var days: Int = 0
        
        switch currentDate {
        case "1", "3", "5", "7", "8", "10", "12":
            days = 31
            break
        case "2":
            if (Int(currentYear)! % 400 == 0 || (Int(currentYear)! % 100 != 0 && Int(currentYear)! % 4 == 0)) {
                days = 29
                break
            } else {
                days = 28
                break
            }
        default:
            days = 30
            break
        }
        
        for index in 1...days {
            var day = ""
            
            if (index < 10) {
                day = "0\(index)"
            } else {
                day = "\(index)"
            }
            
            let dayOfMonth = "\(currentYear)-\(currentMonth)-\(day)"
            
            formatter.dateFormat = "yyyy-MM-dd"
            let searchDate = formatter.date(from: dayOfMonth)
            self.days.append(searchDate!)
        }
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
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeStudentClassTxt3.isHidden = true
        self.homeStudentClassTxt2.isHidden = true
        self.homeStudentClassTxt.isHidden = true

        setUpDays(self.today)
        
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
        
        self.calendarColor()
        self.calendarEvent()
        self.setCalendar()
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
        
        GetTeacherMyClass(self: self)
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
        
        GetStudentMyClass(self: self)
    }
    
    /// linked button clicked
    @IBAction func ButtonClicked(_ sender: Any) {
        guard let detailClassVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController") as? DetailClassViewController else { return }
        
        GetLinkButtonInfos(sender: sender as! UIButton, firstLabel: HomeStudentIconLabel, secondLabel: HomeStudentIconSecondLabel, thirdLabel: HomeStudentIconThirdLabel, detailVC: detailClassVC, self: self)
    }
    
    /// setting informations
    func getTeacherInfo(){
        GetTeacherInfo(days: self.days, homeStudentScrollView: self.HomeStudentScrollView, stateLabel: self.stateLabel, self: self)
        
        self.id = userEmail
        self.pw = userPW
        self.type = userType
        setTeacherMyClasses()
    }
    
    func getStudentInfo(){
        GetStudentInfo(days: self.days, homeStudentScrollView: self.HomeStudentScrollView, stateLabel: self.stateLabel, self: self)
        
        self.id = userEmail
        self.pw = userPW
        self.type = userType
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
        ShowScheduleList(date: datestr, scheduleListVC: scheduleListVC, self: self)
    }
    
    //이벤트 표시 개수
    public func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if sharedEvents.contains(date) {
            return 1
        } else {
            return 0
        }
    }
    
    public func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if sharedEvents.contains(date) {
            return UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        } else {
            return nil
        }
    }
}

extension HomeViewController: FSCalendarDataSource {
}



