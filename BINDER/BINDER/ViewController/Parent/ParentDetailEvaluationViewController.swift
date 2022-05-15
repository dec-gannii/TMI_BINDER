//
//  ParentDetailEvaluationViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/15.
//

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

// Parent 버전의 더보기 버튼 클릭 시 나타나는 평가 상세보기 화면
public class ParentDetailEvaluationViewController: UIViewController, FSCalendarDataSource {
    @IBOutlet weak var calendarView: FSCalendar! // 월간 캘린더
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView! // 월간 평가가 나타나는 textview
    @IBOutlet weak var monthlyEvaluationTitle: UILabel! // 평가 제목 Label
    @IBOutlet weak var navigationBarTitle: UINavigationItem! // 네비게이션 바
    
    let db = Firestore.firestore()
    
    var studentUid: String! // 학생 Uid
    var studentEmail: String! // 학생 이메일
    var teacherName: String! // 선생님 이름
    var teacherEmail: String! // 선생님 이메일
    var subject: String! // 과목
    var index: Int! // index (학생 순서)
    var month: String! // 월
    var studentName: String! // 학생 이름
    let nowDate = Date() // 오늘 날짜
    
    var events: [Date]!
    var days: [Date]!
    
    var calendarDesign = CalendarDesign()
    var viewDesign = ViewDesign()
    
    func _init(){
        studentUid = ""
        studentEmail = ""
        teacherName = ""
        teacherEmail = ""
        subject = ""
        index = 0
        studentName = ""
    }
    
    @IBAction func prevBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: true) }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: false) }
    
    private var currentPage: Date?
    
    private lazy var today: Date = { return Date() }()
    
    private lazy var dateFormatter: DateFormatter = { let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 MM월"
        return df
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCalendar()
        GetParentInfoForParentDetailVC(self: self)
        GetStudentMonthlyEvaluations(self: self)
        GetStudentDailyEvaluations(self: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.calendarView.reloadData()
    }
    
    func setCalendar() {
        calendarView.delegate = self
        calendarView.headerHeight = 0
        calendarView.scope = .month
        monthLabel.text = self.dateFormatter.string(from: calendarView.currentPage)
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingHUD.hide()
        }
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
   
    // 캘린더 텍스트 스타일 설정을 위한 메소드
    func calendarText() {
        calendarView.headerHeight = 0
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    func calendarColor() {
        calendarView.appearance.weekdayTextColor = .systemGray
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.headerTitleColor =  calendarDesign.calendarColor
        calendarView.appearance.eventDefaultColor = UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        calendarView.appearance.eventSelectionColor = UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        
        calendarView.appearance.titleSelectionColor = calendarDesign.calendarColor
        calendarView.appearance.borderSelectionColor = UIColor(red: 205, green: 231, blue: 252, alpha: 1)
        calendarView.appearance.titleTodayColor = UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        calendarView.appearance.todaySelectionColor = UIColor(red: 205, green: 231, blue: 252, alpha: 1)
        calendarView.appearance.selectionColor = .none
        calendarView.appearance.todayColor = UIColor(red: 205, green: 231, blue: 252, alpha: 1)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        events = []
        self.days = setUpDays(self.today)
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        monthlyEvaluationTextView.textContainerInset = viewDesign.EdgeInsets
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM" // 날짜가 표시될 타임 설정
        self.month = dateFormatter.string(from: self.nowDate) + "월" // 월 정보에 오늘에 해당하는 월 설저
        self.monthlyEvaluationTextView.isEditable = false // 평가 뷰는 수정되면 안 되므로 수정 불가능하도록 설정
        
        // calendar 커스터마이징
        calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        /// parent collection에서 현재 사용자의 uid와 동일한 값의 uid를 가지는 문서 찾기
        GetChildrenInfo(self: self)
    }
    
    /// 뒤로가기 버튼 클릭 시 실행
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ParentDetailEvaluationViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate, FSCalendarDelegateAppearance {
    /// 날짜 선택 시 실행되는 메소드
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        /// 선생님 평가 view controller 띄우기
        guard let teacherEvaluationVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherEvaluationViewController") as? TeacherEvaluationViewController else {
            //아니면 종료
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let selectedMonth = dateFormatter.string(from: date) + "월"
        self.month = selectedMonth // 선택된 달로 self.month에 할당
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let selectedDate = dateFormatter.string(from: date)
        
        // 아래에서 위로 뜨는 modal로 설정
        teacherEvaluationVC.modalTransitionStyle = .coverVertical
        teacherEvaluationVC.modalPresentationStyle = .pageSheet
        
        // 필요한 정보들 넘겨주기
        teacherEvaluationVC.teacherName = self.teacherName
        teacherEvaluationVC.teacherEmail = self.teacherEmail
        teacherEvaluationVC.subject = self.subject
        teacherEvaluationVC.month = selectedMonth
        teacherEvaluationVC.date = selectedDate
        
        // 선생님 평가 view controller present
        self.present(teacherEvaluationVC, animated: true)
    }
    
    /// 캘린더의 현재 페이지가 달라진 경우 실행되는 메소드
    public func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingHUD.hide()
        }
        
        let currentPageDate = calendar.currentPage // 현재 페이지 정보
        
        self.monthLabel.text = self.dateFormatter.string(from: calendar.currentPage)
        
        let month = Calendar.current.component(.month, from: currentPageDate) // 현재 페이지의 날짜에서 '월' 정보
        if (month < 10) { // 월이 1-9월 사이면
            self.month = "0\(month)월" // 앞에 0 붙여주기
        } else { // 10월 이후면 그냥 저장
            self.month = "\(month)월"
        }
        
        self.days.removeAll()
        self.events.removeAll()
        
        self.monthLabel.text = self.dateFormatter.string(from: calendarView.currentPage)
        let date = self.dateFormatter.date(from: self.monthLabel.text!)
        
        self.days = setUpDays(date!)
        GetStudentMonthlyEvaluations(self: self)
    }
    
    //이벤트 표시 개수
    public func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.events.contains(date) {
            return 1
        } else {
            return 0
        }
    }
    
    public func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if self.events.contains(date) {
            return UIColor(red: 1, green: 104, blue: 255, alpha: 1)
        } else {
            return nil
        }
    }
}
