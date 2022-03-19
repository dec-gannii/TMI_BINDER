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
class ParentDetailEvaluationViewController: UIViewController, FSCalendarDataSource {
    @IBOutlet weak var calendarView: FSCalendar! // 월간 캘린더
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView! // 월간 평가가 나타나는 textview
    @IBOutlet weak var monthlyEvaluationTitle: UILabel! // 평가 제목 Label
    @IBOutlet weak var monthlyEvaluationTitleBackgroundView: UIView! // 평가가 나타나는 위치의 배경 view
    @IBOutlet weak var navigationBarTitle: UINavigationItem! // 네비게이션 바
    
    let db = Firestore.firestore()
    
    var studentUid: String = "" // 학생 Uid
    var teacherName: String = "" // 선생님 이름
    var teacherEmail: String = "" // 선생님 이메일
    var subject: String = "" // 과목
    var index: Int = 0 // index (학생 순서)
    var month: String = "" // 월
    var studentName: String = "" // 학생 이름
    let nowDate = Date() // 오늘 날짜
    
    @IBAction func prevBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: true) }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) { scrollCurrentPage(isPrev: false) }

    private var currentPage: Date?
    
    private lazy var today: Date = { return Date() }()
    
    private lazy var dateFormatter: DateFormatter = { let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 MM월"
        return df
    }()
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        setCalendar()
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
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    // 캘린더 외관을 꾸미기 위한 메소드
    func calendarColor() {
        calendarView.appearance.weekdayTextColor = .systemGray
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.headerTitleColor =  UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
        calendarView.appearance.eventDefaultColor = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
        calendarView.appearance.eventSelectionColor = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
        calendarView.appearance.selectionColor = .none
        calendarView.appearance.titleSelectionColor = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
        calendarView.appearance.todayColor = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 0.3)
        calendarView.appearance.titleTodayColor = .black
        calendarView.appearance.todaySelectionColor = .white
        calendarView.appearance.borderSelectionColor = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
    }
    
    // 캘린더 텍스트 스타일 설정을 위한 메소드
    func calendarText() {
        calendarView.headerHeight = 0
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        monthlyEvaluationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM" // 날짜가 표시될 타임 설정
        self.month = dateFormatter.string(from: self.nowDate) + "월" // 월 정보에 오늘에 해당하는 월 설저
        self.monthlyEvaluationTextView.isEditable = false // 평가 뷰는 수정되면 안 되므로 수정 불가능하도록 설정
        
        getUserInfo() // 사용자 정보 가져오기
        
        // calendar 커스터마이징
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        /// cornerRadius 지정을 위해 사용
        monthlyEvaluationTitleBackgroundView.clipsToBounds = true
        monthlyEvaluationTitleBackgroundView.layer.cornerRadius = 15
        monthlyEvaluationTextView.clipsToBounds = true
        monthlyEvaluationTextView.layer.cornerRadius = 15
        
        /// 위쪽 코너에만 cornerRadius 주기 위해 사용
        monthlyEvaluationTitleBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(monthlyEvaluationTitleBackgroundView)
        
        /// 이래쪽 코너에만 cornerRadius 주기 위해 사용
        monthlyEvaluationTextView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.addSubview(monthlyEvaluationTextView)
        
        /// parent collection에서 현재 사용자의 uid와 동일한 값의 uid를 가지는 문서 찾기
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
                    let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
                    
                    /// student collection에서 위에서 가져온 childPhoneNumber와 동일한 휴대전화 번호 정보를 가지는 사람이 있는지 찾기
                    self.db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let studentName = document.data()["name"] as? String ?? "" // 학생 이름
                                self.studentName = studentName // self.studentName에 저자
                                self.monthlyEvaluationTitle.text = "이번 달 " + studentName + " 학생은..." // 이번 달 평가 제목에 사용
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 사용자 정보 가져오기
    func getUserInfo() {
        /// parent collection / 현재 사용자 uid의 경로에서 정보를 가져오기
        self.db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let childPhoneNumber = data!["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
                
                /// student collection에서 위에서 가져온 childPhoneNumber와 동일한 휴대전화 번호 정보를 가지는 사람이 있는지 찾기
                self.db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        // 현재로 설정된 달의 월말 평가가 등록되지 않은 경우
                        self.monthlyEvaluationTextView.text = "\(self.month)달 월말 평가가 등록되지 않았습니다."
                        
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let studentUid = document.data()["uid"] as? String ?? "" // 학생 uid
                            
                            /// student collection / studentUid / class collection에서 index필드의 값이 self.index와 동일한 문서를 찾기
                            self.db.collection("student").document(studentUid).collection("class").whereField("index", isEqualTo: self.index).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let name = document.data()["name"] as? String ?? "" // 선생님 이름
                                        self.teacherName = name // 선생님 이름으로 설정
                                        let email = document.data()["email"] as? String ?? "" // 선생님 이메일
                                        self.teacherEmail = email // 선생님 이메일로 설정
                                        let subject = document.data()["subject"] as? String ?? "" // 과목
                                        self.subject = subject // 과목으로 설정
                                        
                                        self.navigationBarTitle.title = self.studentName + " 학생 " + self.subject + " 월말평가" // navigationBar의 title text에 학생 이름과 과목을 포함하여 지정
                                        
                                        /// student collection / studentUid / class / 선생님이름(선생님이메일) 과목 / Evaluation 경로에서 month가 현재 설정된 달의 값과 같은 문서 찾기
                                        self.db.collection("student").document(studentUid).collection("class").document(name + "(" + email + ") " + self.subject).collection("Evaluation").whereField("month", isEqualTo: self.month).getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print(">>>>> document 에러 : \(err)")
                                            } else {
                                                for document in querySnapshot!.documents {
                                                    let evaluationData = document.data()
                                                    let evaluation = evaluationData["evaluation"] as? String ?? "아직 이번 달 월말 평가가 등록되지 않았습니다." // 평가 내용 정보
                                                    self.monthlyEvaluationTextView.text = evaluation // 평가 내용 text로 설정
                                                    self.monthlyEvaluationTextView.isEditable = false // 수정 불가능하도록 설정
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
    
    /// 뒤로가기 버튼 클릭 시 실행
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ParentDetailEvaluationViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    /// 날짜 선택 시 실행되는 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
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
        
        // 아래에서 위로 뜨는 modal로 설정
        teacherEvaluationVC.modalTransitionStyle = .coverVertical
        teacherEvaluationVC.modalPresentationStyle = .pageSheet
        
        // 필요한 정보들 넘겨주기
        teacherEvaluationVC.teacherName = self.teacherName
        teacherEvaluationVC.teacherEmail = self.teacherEmail
        teacherEvaluationVC.subject = self.subject
        teacherEvaluationVC.month = selectedMonth
        
        // 선생님 평가 view controller present
        self.present(teacherEvaluationVC, animated: true)
    }
    
    /// 캘린더의 현재 페이지가 달라진 경우 실행되는 메소드
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        let currentPageDate = calendar.currentPage // 현재 페이지 정보
        
        self.monthLabel.text = self.dateFormatter.string(from: calendar.currentPage)
        
        let month = Calendar.current.component(.month, from: currentPageDate) // 현재 페이지의 날짜에서 '월' 정보
        if (month < 10) { // 월이 1-9월 사이면
            self.month = "0\(month)월" // 앞에 0 붙여주기
        } else { // 10월 이후면 그냥 저장
            self.month = "\(month)월"
        }
        getUserInfo() // 사용자 정보 가져오기
    }
}
