//
//  DetailClassViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/26.
//

import UIKit
import Firebase
import FSCalendar
import Charts
import BLTNBoard

class DetailClassViewController: UIViewController {
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var todoTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var homeworkLabel: UILabel!
    @IBOutlet weak var evaluationLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationBackgroundView: UIView!
    @IBOutlet weak var monthlyEvaluationQuestionLabel: UILabel!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    
    // 넘겨주기 위한 변수들
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var currentCnt: Int = 0
    var days: [String]!
    var scores: [Double]!
    let floatValue: [CGFloat] = [5,5]
    var barColors = [UIColor]()
    var count = 0
    var todos = Array<String>()
    var bRec:Bool = false
    var date: String!
    var selectedMonth: String!
    var userIndex: Int!
    var keyHeight: CGFloat?
    var checkTime: Bool = false
    
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
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
    @IBOutlet weak var EvaluationTitleLabel: UILabel!
    @IBOutlet weak var classTimeTextField: UITextField!
    @IBOutlet weak var monthlyEvaluationOKBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        getScores()
        getUserInfo()
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        allRound()
        barColorSetting()
    }
    
    func setBorder() {
        let color = UIColor.systemGray6.cgColor
        self.progressTextView.layer.borderWidth = 1.0
        self.progressTextView.layer.borderColor = color
        self.evaluationMemoTextView.layer.borderWidth = 1.0
        self.evaluationMemoTextView.layer.borderColor = color
        self.monthlyEvaluationTextView.layer.borderWidth = 1.0
        self.monthlyEvaluationTextView.layer.borderColor = color
        
    }
    
    override func viewDidLoad() {
        // 빈 배열 형성
        days = []
        scores = []
        
        let EdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        monthlyEvaluationTextView.textContainerInset = EdgeInsets
        evaluationMemoTextView.textContainerInset = EdgeInsets
        progressTextView.textContainerInset = EdgeInsets
        
        self.monthlyEvaluationBackgroundView.isHidden = true
        
        // 데이터 없을 때 나올 텍스트 설정
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        
        setBorder()
        
        evaluationView.isHidden = true
        evaluationOKBtn.isHidden = true
        
        if (self.userName != nil) { // 사용자 이름이 nil이 아닌 경우
            if (self.userType == "student") { // 사용자가 학생이면
                self.classNavigationBar.topItem!.title = self.userName + " 선생님"
                self.questionLabel.text = "오늘 " + self.userName + " 선생님의 수업은 어땠나요?"
                self.classTimeTextField.isEnabled = false
                self.progressLabel.text = "오늘 내용 요약"
                self.homeworkLabel.text = "수업 준비 점수"
                self.evaluationLabel.text = "수업 만족도 점수"
                self.testLabel.text = "수업 난이도 점수"
            } else { // 사용자가 학생이 아니면(선생님이면)
                self.monthlyEvaluationBackgroundView.isHidden = true
                self.classNavigationBar.topItem!.title = self.userName + " 학생"
                self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
            }
        }
        super.viewDidLoad()
    }
    
    // 캘린더 외관을 꾸미기 위한 메소드
    func calendarColor() {
        let color = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
        calendarView.scope = .week
        calendarView.appearance.weekdayTextColor = .systemGray
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.headerTitleColor =  color
        calendarView.appearance.eventDefaultColor = color
        calendarView.appearance.eventSelectionColor = color
        calendarView.appearance.titleSelectionColor = color
        calendarView.appearance.borderSelectionColor = color
        calendarView.appearance.todayColor = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 0.3)
        calendarView.appearance.titleTodayColor = .black
        calendarView.appearance.todaySelectionColor = .white
        calendarView.appearance.selectionColor = .none
    }
    
    // 캘린더 텍스트 스타일 설정을 위한 메소드
    func calendarText() {
        calendarView.headerHeight = 16
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 12)
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 13)
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 12)
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.weekdayHeight = 14
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 사용자의 정보를 가져오도록 하는 메소드
    func getUserInfo() {
        var docRef = self.db.collection("teacher") // 선생님이면
        docRef.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents { // 문서가 있다면
                        print("\(document.documentID) => \(document.data())")
                        // 선생님이므로 성적 추가하는 버튼은 보이지 않도록 isHidden을 true로 변경
                        self.plusButton.isHidden = true
                        
                        if let index = self.userIndex { // userIndex가 nil이 아니라면
                            // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
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
                                                let payType = document.data()["payType"] as? String ?? ""
                                                
                                                if (payType == "T") {
                                                    self.classTimeTextField.isEnabled = true
                                                } else if (payType == "C") {
                                                    self.classTimeTextField.isEnabled = false
                                                }
                                                
                                                let currentCnt = document.data()["currentCnt"] as? Int ?? 0
                                                self.currentCnt = currentCnt
                                                self.userName = name
                                                self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
                                                self.userEmail = document.data()["email"] as? String ?? ""
                                                self.userSubject = document.data()["subject"] as? String ?? ""
                                                self.monthlyEvaluationQuestionLabel.text = "이번 달 " + self.userName + " 학생은 전반적으로 어땠나요?"
                                                self.classNavigationBar.topItem!.title = self.userName + " 학생"
                                                
                                                // todolist도 가져오기
                                                self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").document("todos").getDocument {(document, error) in
                                                    if let document = document, document.exists {
                                                        let data = document.data()
                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                        self.count = data?["count"] as? Int ?? 0
                                                        
                                                        for i in 1...self.count {
                                                            // 순서대로 todolist를 담는 배열에 추가해주기
                                                            self.todos.append(data?["todo\(i)"] as! String)
                                                        }
                                                        print("Document data: \(dataDescription)")
                                                    } else {
                                                        print("Document does not exist")
                                                    }
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        
        // 학생이면
        docRef = self.db.collection("student")
        // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        docRef.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let studentName = document.data()["name"] as? String ?? ""
                        let studentEmail = document.data()["email"] as? String ?? ""
                        let teacherDocRef = self.db.collection("teacher")
                        
                        if let email = self.userEmail { // 사용자의 이메일이 nil이 아니라면
                            // 선생님들 정보의 경로 중 이메일이 일치하는 선생님 찾기
                            teacherDocRef.whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let teacherUid = document.data()["uid"] as? String ?? ""
                                        
                                        // 선생님의 수업 목록 중 학생과 일치하는 정보 불러오기
                                        self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.userSubject).collection("ToDoList").document("todos").getDocument {(document, error) in
                                            if let document = document, document.exists {
                                                let data = document.data()
                                                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                self.count = data?["count"] as? Int ?? 0
                                                self.questionLabel.text = "오늘 " + self.userName + " 선생님의 수업은 어땠나요?"
                                                
                                                // todolist 배열에 요소 추가
                                                for i in 1...self.count {
                                                    self.todos.append(data?["todo\(i)"] as! String)
                                                }
                                                print("Document data: \(dataDescription)")
                                            } else {
                                                print("Document does not exist")
                                            }
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                        // 학생이면 투두리스트 추가를 하지 못하도록 설정
                        self.okButton.isHidden = true
                        self.todoTF.isHidden = true
                        self.plusButton.isHidden = false
                        
                        // 학생이면 수업 수정 버튼 보이지 않도록 설정
                        self.editBtn.isHidden = true
                    }
                }
            }
    }
    
    // 학생이 입력해둔 성적 수치를 가져오기 위한 메소드
    func getScores() {
        var studentUid = "" // 학생의 uid 변수
        // 빈 배열 형성
        days = []
        scores = []
        
        // 받은 이메일이 nil이 아니라면
        if let email = self.userEmail {
            let studentDocRef = self.db.collection("student")
            var studentEmail = ""
            if (self.userType == "student") { // 현재 로그인한 사용자가 학생이라면 현재 사용자의 이메일 받아오기
                studentEmail = (Auth.auth().currentUser?.email)!
            } else { // 아니라면 전 view controller에서 받아온 이메일로 설정
                studentEmail = email
            }
            
            // 학생의 정보들 중 이메일이 동일한 정보 불러오기
            studentDocRef.whereField("email", isEqualTo: studentEmail).getDocuments() {
                (QuerySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in QuerySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        studentUid = document.data()["uid"] as? String ?? "" // 학생의 uid 변수에 저장
                    }
                }
                
                // 그래프 정보 저장 경로
                let docRef = self.db.collection("student").document(studentUid).collection("Graph")
                docRef.document("Count").getDocument {(document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        let countOfScores = data?["count"] as? Int ?? 0
                        docRef.whereField("isScore", isEqualTo: "true")
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let type = document.data()["type"] as? String ?? ""
                                        let score = Double(document.data()["score"] as? String ?? "0.0")
                                        if (countOfScores > 0) {
                                            if (countOfScores == 1) {
                                                self.days.insert(type, at: 0)
                                                self.scores.insert(score!, at: 0)
                                            } else {
                                                for i in stride(from: 0, to: 1, by: 1) {
                                                    print ("i : \(i)")
                                                    self.days.insert(document.data()["type"] as? String ?? "", at: i)
                                                    self.scores.insert(Double(document.data()["score"] as? String ?? "0.0")!, at: i)
                                                }
                                            }
                                            self.setChart(dataPoints: self.days, values: self.scores)
                                        } else {
                                            self.barChartView.noDataText = "데이터가 없습니다."
                                            self.barChartView.noDataFont = .systemFont(ofSize: 20)
                                            self.barChartView.noDataTextColor = .lightGray
                                        }
                                    }
                                }
                            }
                        print("Document data: \(dataDescription)")
                    } else {
                        print("Document does not exist")
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    // 뒤로가기 버튼 클릭 시 실행되는 메소드
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func SaveMonthlyEvaluation(_ sender: Any) {
        let date = self.selectedMonth + "월"
        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument {(document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let teacherName = data!["name"] as? String ?? ""
                let teacherEmail = data!["email"] as? String ?? ""
                
                if let email = self.userEmail {
                    self.db.collection("student").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let uid = document.data()["uid"] as? String ?? ""
                                
                                self.db.collection("student").document(uid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).collection("Evaluation").document(date).setData([
                                    "month": date,
                                    "isMonthlyEvaluation": true,
                                    "evaluation": self.monthlyEvaluationTextView.text!
                                ]) { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        self.monthlyEvaluationBackgroundView.isHidden = true
    }
    
    @IBAction func editBtnAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: "수정 및 삭제", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default, handler: { action in
            guard let editClassVC = self.storyboard?.instantiateViewController(withIdentifier: "EditClassViewController") as? EditClassVC else { return }
            
            editClassVC.modalTransitionStyle = .crossDissolve
            editClassVC.modalPresentationStyle = .fullScreen
            
            // 값 보내주는 역할
            editClassVC.userName = self.userName
            editClassVC.userEmail = self.userEmail
            editClassVC.userSubject = self.userSubject
            
            self.present(editClassVC, animated: true, completion: nil)
            
        })
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: { action in
            let path  =  self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject)
            
            path.delete()
            
            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument {(document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let teacherName = data!["name"] as? String ?? ""
                    let teacherEmail = data!["email"] as? String ?? ""
                    if let email = self.userEmail {
                        let studentPath = self.db.collection("student").whereField("email", isEqualTo: email)
                        studentPath.getDocuments() {
                            (QuerySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in QuerySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let studentUid = document.data()["uid"] as? String ?? "" // 학생의 uid 변수에 저장
                                    let studentClassPath = self.db.collection("student").document(studentUid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject)
                                    studentClassPath.delete()
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    // 평가 저장하기 버튼 클릭 시 실행되는 메소드
    @IBAction func OKButtonClicked(_ sender: Any) {
        // 경로는 각 학생의 class의 Evaluation
        if(self.userType == "teacher") {
            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)").setData([
                "progress": progressTextView.text!,
                "testScore": Int(testScoreTextField.text!) ?? 0,
                "homeworkCompletion": Int(homeworkScoreTextField.text!) ?? 0,
                "classAttitude": Int(classScoreTextField.text!) ?? 0,
                "evaluationMemo": evaluationMemoTextView.text!,
                "evaluationDate": self.date ?? "",
                "todayClassTime": Int(self.classTimeTextField.text!) ?? 0
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
            
            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    var currentCnt = data?["currentCnt"] as? Int ?? 0
                    let subject = data?["subject"] as? String ?? "" // 과목
                    let payType = data?["payType"] as? String ?? ""
                    var count = 0
                    
                    if (payType == "T") {
                        if (currentCnt+Int(self.classTimeTextField.text!)! >= 8) {
                            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                                "currentCnt": (currentCnt + Int(self.classTimeTextField.text!)!) % 8
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        } else {
                            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                                "currentCnt": currentCnt + Int(self.classTimeTextField.text!)!
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        }
                        count = currentCnt + Int(self.classTimeTextField.text!)!
                    } else if (payType == "C") {
                        if (currentCnt+1 >= 8) {
                            currentCnt = currentCnt % 8
                            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                                "currentCnt": currentCnt + 1
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        } else {
                            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                                "currentCnt": currentCnt + 1
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        }
                        count = currentCnt + 1
                    }
                    
                    self.db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let name =  data?["name"] as? String ?? "" // 선생님 이름
                            let email = data?["email"] as? String ?? "" // 선생님 이메일
                            
                            self.db.collection("student").whereField("email", isEqualTo: self.userEmail!).getDocuments() { (querySnapshot, err) in
                                if let err = err { // 학생 이메일이랑 같으면
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        // 사용할 것들 가져와서 지역 변수로 저장
                                        let uid = document.data()["uid"] as? String ?? "" // 학생 uid
                                        let path = name + "(" + email + ") " + subject
                                        self.db.collection("student").document(uid).collection("class").document(path).updateData([
                                            "currentCnt": count,
                                        ]) { err in
                                            if let err = err {
                                                print("Error adding document: \(err)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
            self.evaluationView.isHidden = true
            evaluationOKBtn.isHidden = true
        } else if (self.userType == "student") {
            self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)").setData([
                "summary": progressTextView.text!,
                "prepare": Int(testScoreTextField.text!) ?? 0,
                "satisfy": Int(homeworkScoreTextField.text!) ?? 0,
                "level": Int(classScoreTextField.text!) ?? 0,
                "evaluationMemo": evaluationMemoTextView.text!,
                "evaluationDate": self.date ?? ""
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
        }
    }
    
    func allRound() {
        okButton.clipsToBounds = true
        okButton.layer.cornerRadius = 10
        plusButton.clipsToBounds = true
        plusButton.layer.cornerRadius = 10
        evaluationView.layer.cornerRadius = 10
        monthlyEvaluationBackgroundView.layer.cornerRadius = 10
        monthlyEvaluationTextView.layer.cornerRadius = 10
        progressTextView.layer.cornerRadius = 10
        evaluationMemoTextView.layer.cornerRadius = 10
        evaluationOKBtn.layer.cornerRadius = 10
        monthlyEvaluationOKBtn.layer.cornerRadius = 10
    }
    
    func barColorSetting(){
        barColors.append(UIColor.init(displayP3Red: 22/255, green: 32/255, blue: 60/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 82/255, green: 90/255, blue: 109/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 126/255, green: 129/255, blue: 144/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 146/255, green: 150/255, blue: 160/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 175/255, green: 178/255, blue: 186/255, alpha: 1))
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "성적 그래프")
        
        // 차트 컬러
        chartDataSet.colors = barColors
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.drawValueAboveBarEnabled = true
        
        // 선택 안되게
        chartDataSet.highlightEnabled = false
        
        // 줌 안되게
        barChartView.doubleTapToZoomEnabled = false
        
        // 차트 점선으로 표시
        barChartView.xAxis.gridColor = .clear
        barChartView.leftAxis.gridColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.4)
        barChartView.leftAxis.gridLineWidth = CGFloat(1.0)
        barChartView.leftAxis.gridLineDashLengths = floatValue
        barChartView.leftAxis.axisMaximum = 100
        barChartView.leftAxis.axisMinimum = 0
        
        // X축 레이블 위치 조정
        barChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        barChartView.legend.setCustom(entries: [])
        
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        barChartView.xAxis.setLabelCount(dataPoints.count, force: false)
        
        // 오른쪽 레이블 제거
        barChartView.rightAxis.enabled = false
        
        // 기본 애니메이션
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    @IBAction func PlusScores(_ sender: Any) {
        guard let plusGraphVC = self.storyboard?.instantiateViewController(withIdentifier: "PlusGraphViewController") as? PlusGraphViewController else { return }
        
        plusGraphVC.modalTransitionStyle = .crossDissolve
        plusGraphVC.modalPresentationStyle = .fullScreen
        
        // 값 보내주는 역할
        plusGraphVC.userName = self.userName
        plusGraphVC.userEmail = self.userEmail
        plusGraphVC.userSubject = self.userSubject
        
        self.present(plusGraphVC, animated: true, completion: nil)
    }
    
    //투두리스트 추가 버튼 클릭시
    @IBAction func goButtonClicked(_ sender: Any) {
        if todoTF.text != "" {
            todos.append(todoTF.text ?? "")
            count = count + 1
            
            let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").document("todos")
            
            if (count == 1) {
                docRef.setData([
                    "count": count,
                    "check": checkTime,
                    "todo\(count)":todoTF.text ?? ""
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            } else {
                docRef.updateData([
                    "count": count,
                    "check":checkTime,
                    "todo\(count)":todoTF.text ?? ""
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            }
            todoTF.text = ""
            self.tableView.reloadData()
        }
    }
}

extension DetailClassViewController:UITableViewDataSource, UITableViewDelegate {
    
    //데이터 카운트
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    // 데이터 나타내기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as! Todocell
        let todo = self.todos[indexPath.row]
        let background = UIView()
        
        cell.TodoLabel.text = "\(todo)"
        cell.CheckButton.addTarget(self, action: #selector(checkMarkButtonClicked(sender:)),for: .touchUpInside)
        return cell
    }
    
    // 데이터 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if self.userType == "teacher" {
            if editingStyle == .delete {
                
                todos.remove(at: indexPath.row)
                count = count - 1
                
                let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").document("todos")
                
                docRef.updateData([
                    "count": count
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                for i in 1...self.count {
                    docRef.updateData([
                        "todo\(i)":todos[i]
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } else if editingStyle == .insert {
                
            }
        }
    }
    
    // 투두리스트 선택에 따라
    @objc func checkMarkButtonClicked(sender: UIButton){
        
        if sender.isSelected{
            sender.isSelected = false
            checkTime = false
            //체크 내용 업데이트
            print("button normal")
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
            
        } else {
            sender.isSelected = true
            checkTime = true
            // 체크 내용 업데이트
            print("button selected")
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        }
    }
}

extension DetailClassViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate, UITextViewDelegate {
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        if (self.userType == "teacher") {
            if (self.currentCnt % 8 == 0 && (self.currentCnt == 0 || self.currentCnt == 8)) {
                self.monthlyEvaluationBackgroundView.isHidden = false
            } else {
                self.monthlyEvaluationBackgroundView.isHidden = true
            }
        } else {
            self.monthlyEvaluationBackgroundView.isHidden = true
        }
        
        let selectedDate = date
        let nowDate = Date()
        
        // 수업을 하지 않은 미래의 수업에 대해서는 평가를 할 수 없도록 하기 위해서 오늘 날짜와 선택한 날짜 비교
        let distanceDay = Calendar.current.dateComponents([.day], from: selectedDate, to: nowDate).day
        
        // 차이가 0보다 작거나 같으면
        if (!(distanceDay! <= 0)) {
            // 평가 입력 뷰를 숨김 해제
            evaluationView.isHidden = false
            evaluationOKBtn.isHidden = false
            
            self.classTimeTextField.text = ""
            self.testScoreTextField.text = ""
            self.classScoreTextField.text = ""
            self.homeworkScoreTextField.text = ""
            self.evaluationMemoTextView.text = ""
            self.progressTextView.text = ""
            
            // 날짜 받아와서 변수에 저장
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            let dateStr = dateFormatter.string(from: selectedDate)
            self.date = dateStr
            
            dateFormatter.dateFormat = "MM"
            let monthStr = dateFormatter.string(from: selectedDate)
            self.selectedMonth = monthStr
            
            // 데이터베이스 경로
            if (self.userType == "teacher") {
                let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document(dateStr)
                
                // 데이터를 받아와서 각각의 값에 따라 textfield 값 설정 (만약 없다면 공백 설정, 있다면 그 값 불러옴)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        self.date = data?["evaluationDate"] as? String ?? ""
                        
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        
                        let homeworkCompletion = data?["homeworkCompletion"] as? Int ?? 0
                        if (homeworkCompletion == 0) {
                            self.homeworkScoreTextField.text = ""
                        } else {
                            self.homeworkScoreTextField.text = "\(homeworkCompletion)"
                        }
                        
                        let classAttitude = data?["classAttitude"] as? Int ?? 0
                        if (classAttitude == 0) {
                            self.classScoreTextField.text = ""
                        } else {
                            self.classScoreTextField.text = "\(classAttitude)"
                        }
                        
                        let progressText = data?["progress"] as? String ?? ""
                        self.progressTextView.textColor = .black
                        if (progressText != "") {
                            self.progressTextView.text = progressText
                        }
                        
                        let evaluationMemo = data?["evaluationMemo"] as? String ?? ""
                        self.evaluationMemoTextView.textColor = .black
                        if (evaluationMemo != "") {
                            self.evaluationMemoTextView.text = evaluationMemo
                        }
                        
                        let todayClassTime = data?["todayClassTime"] as? Int ?? 0
                        if (todayClassTime == 0) {
                            self.classTimeTextField.text = ""
                        } else {
                            self.classTimeTextField.text = "\(todayClassTime)"
                        }
                        
                        let testScore = data?["testScore"] as? Int ?? 0
                        if (testScore == 0) {
                            self.testScoreTextField.text = ""
                        } else {
                            self.testScoreTextField.text = "\(testScore)"
                        }
                        print("Document data: \(dataDescription)")
                    } else {
                        print("Document does not exist")
                        // 값 다시 공백 설정
                        self.testScoreTextField.text = ""
                        self.homeworkScoreTextField.text = ""
                        self.classScoreTextField.text = ""
                    }
                }
                
                self.db.collection("student").whereField("email", isEqualTo: self.userEmail).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents { // 문서가 있다면
                            print("\(document.documentID) => \(document.data())")
                            let studentUid = document.data()["uid"] as? String ?? ""
                            
                            self.db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents { // 문서가 있다면
                                        print("\(document.documentID) => \(document.data())")
                                        let teacherName = document.data()["name"] as? String ?? ""
                                        let teacherEmail = document.data()["email"] as? String ?? ""
                                        
                                        self.db.collection("student").document(studentUid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).collection("Evaluation").document(self.selectedMonth + "월").getDocument(){ (document, error) in
                                            if let document = document, document.exists {
                                                let data = document.data()
                                                let evaluation = data!["evaluation"] as? String ?? ""
                                                self.monthlyEvaluationTextView.text = evaluation
                                                self.monthlyEvaluationTextView.textColor = .black
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else if (self.userType == "student") {
                let docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)")
                
                // 데이터를 받아와서 각각의 값에 따라 textfield 값 설정 (만약 없다면 공백 설정, 있다면 그 값 불러옴)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        self.date = data?["evaluationDate"] as? String ?? ""
                        
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        
                        let prepare = data?["prepare"] as? Int ?? 0
                        if (prepare == 0) {
                            self.homeworkScoreTextField.text = ""
                        } else {
                            self.homeworkScoreTextField.text = "\(prepare)"
                        }
                        
                        let summary = data?["summary"] as? Int ?? 0
                        if (summary == 0) {
                            self.progressTextView.text = ""
                        } else {
                            self.progressTextView.text = "\(summary)"
                        }
                        
                        let satisfy = data?["satisfy"] as? Int ?? 0
                        if (summary == 0) {
                            self.classScoreTextField.text = ""
                        } else {
                            self.classScoreTextField.text = "\(satisfy)"
                        }
                        
                        let evaluationMemo = data?["evaluationMemo"] as? String ?? ""
                        self.evaluationMemoTextView.text = evaluationMemo
                        
                        let level = data?["level"] as? Int ?? 0
                        if (level == 0) {
                            self.testScoreTextField.text = ""
                        } else {
                            self.testScoreTextField.text = "\(level)"
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
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool){
        calendarHeight.constant = bounds.height + 20
        self.view.layoutIfNeeded ()
    }
}

extension DetailClassViewController: FSCalendarDataSource {
    
}
