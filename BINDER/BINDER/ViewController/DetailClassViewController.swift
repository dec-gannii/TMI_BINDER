//
//  MyClassViewController.swift
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
    
    //@IBOutlet var plusButton: UIButton!
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var todoTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    
    var days: [String]!
    var scores: [Double]!
    let floatValue: [CGFloat] = [5,5]
    var barColors = [UIColor]()
    var count = 0
    var todos = Array<String>()
    var bRec:Bool = false
    
    var date: String!
    var userIndex: Int!
    var keyHeight: CGFloat?
    
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
    
    override func viewDidLoad() {
        
        //        days = ["3월모고","1학기중간","6월모고","1학기기말"]
        //        scores = [68.0,88.5,70.5,90.0]
        days = []
        scores = []
        getScores()
        getUserInfo()
        
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        
        allRound()
        barColorSetting()
        
        evaluationView.layer.cornerRadius = 10
        
        evaluationView.isHidden = true
        evaluationOKBtn.isHidden = true
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        self.progressTextView.layer.borderWidth = 1.0
        self.progressTextView.layer.borderColor = UIColor.systemGray6.cgColor
        
        self.evaluationMemoTextView.layer.borderWidth = 1.0
        self.evaluationMemoTextView.layer.borderColor = UIColor.systemGray6.cgColor
        
        if (self.userName != nil) {
            if (self.userType == "student") {
                self.classNavigationBar.topItem!.title = self.userName + " 선생님"
            } else {
                self.classNavigationBar.topItem!.title = self.userName + " 학생"
                self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
            }
        }
        print(self.userIndex)
        
        super.viewDidLoad()
    }
    
    // 캘린더 외관을 꾸미기 위한 메소드
    func calendarColor() {
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
    
    // 캘린더 텍스트 스타일 설정을 위한 메소드
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
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 사용자의 정보를 가져오도록 하는 메소드
    func getUserInfo() {
        var docRef = self.db.collection("teacher")
        docRef.whereField("Uid", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("0 : \(document.documentID) => \(document.data())")
                        
                        self.plusButton.isHidden = true
                        if let index = self.userIndex {
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
                                                print("1 : \(document.documentID) => \(document.data())")
                                                
                                                // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                                // 네비게이션 바의 이름도 설정해주기
                                                let name = document.data()["name"] as? String ?? ""
                                                self.userName = name
                                                self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
                                                self.userEmail = document.data()["email"] as? String ?? ""
                                                self.userSubject = document.data()["subject"] as? String ?? ""
                                                
                                                self.classNavigationBar.topItem!.title = self.userName + " 학생"
                                                
                                                self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").document("todos").getDocument {(document, error) in
                                                    if let document = document, document.exists {
                                                        let data = document.data()
                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                        self.count = data?["count"] as? Int ?? 0
                                                        print("count: \(self.count)")
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
                        }
                    }
                }
            }
        
        docRef = self.db.collection("student")
        
        docRef.whereField("Uid", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("2 : \(document.documentID) => \(document.data())")
                        
                        self.okButton.isHidden = true
                        self.todoTF.placeholder = "선생님만 추가 가능합니다."
                        self.todoTF.isEnabled = false
                        self.plusButton.isHidden = false
                        self.calendarView.isHidden = true
                    }
                }
            }
    }
    
    func getScores() {
        var studentUid = ""
        
        if let email = self.userEmail, let name = self.userName, let subject = self.userSubject {
            
            var studentDocRef = self.db.collection("student")
            //                .document(Auth.auth().currentUser!.uid).collection("\(name)(\(email)) \(subject)")
            
            print ("email : \(email)")
            var studentEmail = ""
            if (self.userType == "student") {
                studentEmail = (Auth.auth().currentUser?.email)!
            } else {
                studentEmail = email
            }
            
            studentDocRef.whereField("Email", isEqualTo: studentEmail).getDocuments() {
                (QuerySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in QuerySnapshot!.documents {
                        
                        print("3 :  \(document.documentID) => \(document.data())")
                        
                        studentUid = document.data()["Uid"] as? String ?? ""
                        print ("Uid1 : \(studentUid)")
                    }
                }
                
                let docRef = self.db.collection("student").document(studentUid).collection("Graph")
                docRef.document("Count").getDocument {(document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        let countOfScores = data?["count"] as? Int ?? 0
                        print ("count of doc : \(countOfScores)")
                        docRef.whereField("isScore", isEqualTo: "true")
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("4 : \(document.documentID) => \(document.data())")
                                        
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
                                            print ("days : \(self.days) / scores : \(self.scores)")
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
    
    // 평가 저장하기 버튼 클릭 시 실행되는 메소드
    @IBAction func OKButtonClicked(_ sender: Any) {
        // 경로는 각 학생의 class의 Evaluation
        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)").setData([
            "Progress": progressTextView.text!,
            "TestScore": Int(testScoreTextField.text!) ?? 0,
            "HomeworkCompletion": Int(homeworkScoreTextField.text!) ?? 0,
            "ClassAttitude": Int(classScoreTextField.text!) ?? 0,
            "EvaluationMemo": evaluationMemoTextView.text!,
            "EvaluationDate": self.date ?? ""
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
        evaluationView.isHidden = true
        evaluationOKBtn.isHidden = true
    }
    
    func allRound() {
        okButton.clipsToBounds = true
        okButton.layer.cornerRadius = 10
        
        plusButton.clipsToBounds = true
        plusButton.layer.cornerRadius = 10
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
        // 옵션 애니메이션
        //barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
    }
    
    @IBAction func PlusScores(_ sender: Any) {
        
        guard let plusGraphVC = self.storyboard?.instantiateViewController(withIdentifier: "PlusGraphViewController") as? PlusGraphViewController else { return }
        
        plusGraphVC.modalTransitionStyle = .crossDissolve
        plusGraphVC.modalPresentationStyle = .fullScreen
        
        plusGraphVC.userName = self.userName
        plusGraphVC.userEmail = self.userEmail
        plusGraphVC.userSubject = self.userSubject
        
        self.present(plusGraphVC, animated: true, completion: nil)
    }
    
    @IBAction func goButtonClicked(_ sender: Any) {
        todos.append(todoTF.text ?? "")
        count = count + 1
        
        var docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").document("todos")
        
        if (count == 1) {
            docRef.setData([
                "count": count,
                "todo\(count)":todoTF.text ?? ""
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
        } else {
            docRef.updateData([
                "count": count,
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
    
    /*
     // 그래프를 보여주도록 하는 메소드
     @IBAction func ShowGraph(_ sender: Any) {
     self.evaluationView.isHidden = true
     guard let graphVC = self.storyboard?.instantiateViewController(withIdentifier: "GraphViewController") as? GraphViewController else { return }
     
     graphVC.modalPresentationStyle = .fullScreen
     graphVC.modalTransitionStyle = .crossDissolve
     // 학생의 이름 데이터 넘겨주기
     graphVC.userName = self.userName
     graphVC.userSubject = self.userSubject
     graphVC.userEmail = self.userEmail
     
     self.present(graphVC, animated: true, completion: nil)
     }
     
     // 사용자의 정보를 가져오도록 하는 메소드
     func getUserInfo() {
     // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
     db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: self.userIndex)
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
     self.userName = name
     self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
     self.userEmail = document.data()["email"] as? String ?? ""
     self.userSubject = document.data()["subject"] as? String ?? ""
     
     self.classNavigationBar.topItem!.title = self.userName + " 학생"
     }
     }
     }
     }
     }
     */
}

extension DetailClassViewController:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as! Todocell
        let todo = self.todos[indexPath.row]
        
        cell.TodoLabel.text = "\(todo)"
        
        cell.selectionStyle = .none
        cell.CheckButton.addTarget(self, action: #selector(checkMarkButtonClicked(sender:)),for: .touchUpInside)
        return cell
    }
    
    @objc func checkMarkButtonClicked(sender: UIButton){
        
        if sender.isSelected{
            sender.isSelected = false
            print("button normal")
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
            
        } else {
            sender.isSelected = true
            print("button selected")
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        }
    }
}

extension DetailClassViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    // 날짜를 하나 선택 하면 실행되는 메소드
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        let selectedDate = date
        let nowDate = Date()
        
        // 수업을 하지 않은 미래의 수업에 대해서는 평가를 할 수 없도록 하기 위해서 오늘 날짜와 선택한 날짜 비교
        let distanceDay = Calendar.current.dateComponents([.day], from: selectedDate, to: nowDate).day
        
        // 차이가 0보다 작거나 같으면
        if (!(distanceDay! <= 0)) {
            // 평가 입력 뷰를 숨김 해제
            evaluationView.isHidden = false
            evaluationOKBtn.isHidden = false
            
            // 날짜 받아와서 변수에 저장
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            let dateStr = dateFormatter.string(from: selectedDate)
            self.date = dateStr
            
            // 데이터베이스 경로
            let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)")
            
            // 데이터를 받아와서 각각의 값에 따라 textfield 값 설정 (만약 없다면 공백 설정, 있다면 그 값 불러옴)
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

extension DetailClassViewController: FSCalendarDataSource {
    
}
