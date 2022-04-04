//
//  QuestionListViewController.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import UIKit
import Kingfisher
import Firebase

class QuestionListViewController : BaseVC {
    
    let db = Firestore.firestore()
    var docRef : CollectionReference!
    
    // 네비게이션바
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toggleLabel: UILabel!
    // 뒤로가기 버튼
    @IBOutlet var backbutton: UIView!
    @IBOutlet weak var plusbutton: UIBarButtonItem!
    // 토글
    @IBOutlet weak var answeredToggle: UISwitch!
    // 테이블 뷰 연결
    @IBOutlet weak var questionListTV: UITableView!
    
    @IBAction func clickBackbutton(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func answeredToggleAction(_ sender: Any) {
        setQuestionList()
        questionListTV.reloadData()
    }
    
    // 값을 받아오기 위한 변수들
    var userName : String!
    var subject : String!
    var email : String!
    var answerCheck : Bool!
    var type = ""
    var index : Int!
    var qnum: Int!
    var maxnum = 0
    var teacherUid: String!
    var questionListItems : [QuestionListItem] = []
    var questionAnsweredItems : [QuestionAnsweredListItem] = []
    var questionNotAnsweredItems : [QuestionAnsweredListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answeredToggle.setOn(false, animated: true)
        getUserInfo()
        self.questionListTV.reloadData()
        if (self.userName != nil) { // 사용자 이름이 nil이 아닌 경우
            if (self.type == "student") { // 사용자가 학생이면
                self.navigationBar.topItem!.title = self.userName + " 선생님"
                self.toggleLabel.text = "답변 완료만 보기"
            } else { // 사용자가 학생이 아니면(선생님이면)
                self.navigationBar.topItem!.title = self.userName + " 학생"
                self.toggleLabel.text = "답변 대기만 보기"
            }
        }
    }
    
    func getUserInfo() {
        var docRef = self.db.collection("teacher") // 선생님이면
        docRef.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents { // 문서가 있다면
                        print("\(document.documentID) => \(document.data())")
                        self.type = "teacher"
                        self.toggleLabel.text = "답변 대기만 보기"
                        
                        if let index = self.index { // userIndex가 nil이 아니라면
                            // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                            print ("index : \(index)")
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
//                                                LoadingIndicator.showLoading()
//                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                                    LoadingIndicator.hideLoading()
//                                                }
                                                
                                                LoadingHUD.show()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                    LoadingHUD.hide()
                                                }
                                                
                                                let name = document.data()["name"] as? String ?? ""
                                                self.userName = name
                                                self.email = document.data()["email"] as? String ?? ""
                                                self.subject = document.data()["subject"] as? String ?? ""
                                                self.navigationBar.topItem!.title = self.userName + " 학생"
                                                self.setTeacherQuestion()
                                                self.plusbutton.isEnabled = false
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        
        docRef = self.db.collection("student") // 학생이면
        docRef.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents { // 문서가 있다면
                        print("\(document.documentID) => \(document.data())")
                        
                        if let index = self.index { // userIndex가 nil이 아니라면
                            // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                            self.type = "student"
                            self.toggleLabel.text = "답변 완료만 보기"
                            print ("index : \(index)")
                            self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
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
                                                let email = document.data()["email"] as? String ?? ""
                                                let subject = document.data()["subject"] as? String ?? ""
                                                self.navigationBar.topItem!.title = name + " 선생님"
                                                self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
                                                    self.setStudentQuestion()
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
    
    func setTeacherQuestion() {
        LoginRepository.shared.doLogin {
            /// 클래스 가져오기
            self.setQuestionList()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    func setStudentQuestion() {
        LoginRepository.shared.doLogin {
            /// 클래스 가져오기
            self.setQuestionList()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    /// 질문방 내용 세팅
    // 질문 리스트 가져오기
    func setQuestionList() {
        let db = Firestore.firestore()
        if (self.type == "teacher") {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                    self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                } else {
                    /// nil이 아닌지 확인한다.
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    
                    /// 조회하기 위해 원래 있던 것 들 다 지움
                    self.questionListItems.removeAll()
                    self.questionAnsweredItems.removeAll()
                    self.questionNotAnsweredItems.removeAll()
                    
                    for document in snapshot.documents {
                        print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                        
                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                        let questionDt = document.data()
                        
                        /// nil값 처리
                        let qnumber = questionDt["num"] as? String ?? ""
                        let title = questionDt["title"] as? String ?? ""
                        let answerCheck = questionDt["answerCheck"] as? Bool ?? false
                        let questionContent = questionDt["questionContent"] as? String ?? ""
                        let imgURL = questionDt["imgURL"] as? String ?? ""
                        let email = questionDt["email"] as? String ?? ""
                        
                        
                        if Int(qnumber)! > self.maxnum {
                            self.maxnum = Int(qnumber)!
                        }
                        
                        print("가장 큰 값 : \(self.maxnum)")
                        
                        let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL , questionContent: questionContent, email: email, index: qnumber )
                        
                        let answeredItem = QuestionAnsweredListItem(title: title, answerCheck: answerCheck, imgURL: imgURL, questionContent: questionContent, email: email, index: qnumber)
                        
                        /// 모든 값을 더한다.
                        /// 전체 경우
                        self.questionListItems.append(item)
                        
                        /// 답변 완료일 경우
                        if answerCheck == true {
                            self.questionAnsweredItems.append(answeredItem)
                        } else if answerCheck == false {
                            self.questionNotAnsweredItems.append(answeredItem)
                        }
                    }
                    
                    /// UITableView를 reload 하기
                    self.questionListTV.reloadData()
                }
            }
        } else {
            if let email = self.email, let index = self.index {
                print ("self.index : \(index), self.email : \(email)")
                var studentName = ""
                var studentEmail = ""
                var teacherUid = ""
                
                db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                        self.showDefaultAlert(msg: "질문을 찾는 중 에러가 발생했습니다.")
                    } else {
                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                            return
                        }
                        for document in querySnapshot!.documents {
                            studentName = document.data()["name"] as? String ?? ""
                            studentEmail = document.data()["email"] as? String ?? ""
                            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                    self.showDefaultAlert(msg: "질문을 찾는 중 에러가 발생했습니다.")
                                } else {
                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                        return
                                    }
                                    var teacherEmail = ""
                                    for document in querySnapshot!.documents {
                                        teacherEmail = document.data()["email"] as? String ?? ""
                                    }
                                    
                                    db.collection("teacher").whereField("email", isEqualTo: teacherEmail).getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            print(">>>>> document 에러 : \(err)")
                                            self.showDefaultAlert(msg: "질문을 찾는 중 에러가 발생했습니다.")
                                        } else {
                                            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                return
                                            }
                                            
                                            for document in querySnapshot!.documents {
                                                teacherUid = document.data()["uid"] as? String ?? ""
                                                self.teacherUid = teacherUid
                                                print ("TeacherUID : \(teacherUid)")
                                                
                                                db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").getDocuments() { (querySnapshot, err) in
                                                    if let err = err {
                                                        print(">>>>> document 에러 : \(err)")
                                                        self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                                                    } else {
                                                        /// nil이 아닌지 확인한다.
                                                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                            return
                                                        }
                                                        
                                                        /// 조회하기 위해 원래 있던 것 들 다 지움
                                                        self.questionListItems.removeAll()
                                                        self.questionAnsweredItems.removeAll()
                                                        self.questionNotAnsweredItems.removeAll()
                                                        
                                                        for document in snapshot.documents {
                                                            print("1: >>>>> document 정보 : \(document.documentID) => \(document.data())")
                                                            
                                                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                            let questionDt = document.data()
                                                            
                                                            /// nil값 처리
                                                            let qnumber = questionDt["num"] as? String ?? ""
                                                            let title = questionDt["title"] as? String ?? ""
                                                            let answerCheck = questionDt["answerCheck"] as? Bool ?? false
                                                            let questionContent = questionDt["questionContent"] as? String ?? ""
                                                            let imgURL = questionDt["imgURL"] as? String ?? ""
                                                            let email = questionDt["email"] as? String ?? ""
                                                            
                                                            let qnum = Int(qnumber)!
                                                            self.maxnum = 0
                                                            if qnum > self.maxnum {
                                                                self.maxnum = qnum
                                                            }
                                                            print("가장 큰 값 : \(self.maxnum)")
                                                            
                                                            if (qnumber != "" && title != "" && questionContent != ""){
                                                                let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL , questionContent: questionContent, email: email, index: qnumber )
                                                                
                                                                let answeredItem = QuestionAnsweredListItem(title: title, answerCheck: answerCheck, imgURL: imgURL, questionContent: questionContent, email: email, index: qnumber)
                                                                
                                                                /// 모든 값을 더한다.
                                                                /// 전체 경우
                                                                self.questionListItems.append(item)
                                                                print (self.questionListItems)
                                                                /// 답변 완료일 경우
                                                                if answerCheck == true {
                                                                    self.questionAnsweredItems.append(answeredItem)
                                                                    print (self.questionAnsweredItems)
                                                                } else if answerCheck == false {
                                                                    self.questionNotAnsweredItems.append(answeredItem)
                                                                    print (self.questionNotAnsweredItems)
                                                                }
                                                                
                                                            }
                                                        }
                                                        /// UITableView를 reload 하기
                                                        self.questionListTV.reloadData()
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
        return
    }
    
    @IBAction func clickPlusBtn(_ sender: Any) {
        guard let plusVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionPlusVC") as? QuestionPlusViewController else { return }
        
        plusVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        plusVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        /// first : 여러개가 와도 첫번째 것만 봄.
        
        plusVC.qnum = maxnum + 1
        plusVC.index = index
        plusVC.email = email
        plusVC.userName = userName
        plusVC.type = type
        plusVC.subject = subject
        
        self.present(plusVC, animated: true, completion: nil)
    }
}




// MARK: - 테이블 뷰 관련

extension QuestionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.type == "teacher") {
            if (answeredToggle.isOn) {
                return self.questionNotAnsweredItems.count
            } else {
                return self.questionListItems.count
            }
        } else {
            if (answeredToggle.isOn) {
                return self.questionAnsweredItems.count
            } else {
                return self.questionListItems.count
            }
        }
    }
    
    // 테이블뷰 선택시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 사용자 구별
        if type == "teacher" {
            docRef = db.collection("teacher")
        } else {
            docRef = db.collection("student")
        }
        
        var qindex: Int!
        var name: String!
        var email: String!
        var subject: String!
        var type: String!
        
        docRef.document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: self.index!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    
                    let item:QuestionListItem = self.questionListItems[indexPath.row]
                    
                    if item.answerCheck == true { //답변이 있는 경우
                        guard let qnaVC = self.storyboard?.instantiateViewController(withIdentifier: "QnADetailVC") as? QnADetailViewController else { return }
                        
                        qnaVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        qnaVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                        /// first : 여러개가 와도 첫번째 것만 봄.
                        
                        let questionDt = snapshot.documents.first!.data()
                        
                        qindex = questionDt["index"] as? Int ?? 0
                        name = questionDt["name"] as? String ?? ""
                        subject = questionDt["subject"] as? String ?? ""
                        email = questionDt["email"] as? String ?? ""
                        type = questionDt["type"] as? String ?? ""
                        
                        qnaVC.index = qindex
                        qnaVC.email = email
                        qnaVC.userName = name
                        qnaVC.type = type
                        qnaVC.subject = subject
                        qnaVC.qnum = Int(item.index)
                        
                        self.present(qnaVC, animated: true, completion: nil)
                    }
                    else { // 답변이 없는 경우
                        guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionDetailVC") as? QuestionDetailViewController else { return }
                        
                        questionVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        questionVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                        /// first : 여러개가 와도 첫번째 것만 봄.
                        
                        let questionDt = snapshot.documents.first!.data()
                        print(">>>>> 넘기는 정보 : \(questionDt)")
                        
                        qindex = questionDt["index"] as? Int ?? 0
                        name = questionDt["name"] as? String ?? ""
                        subject = questionDt["subject"] as? String ?? ""
                        email = questionDt["email"] as? String ?? ""
                        type = questionDt["type"] as? String ?? ""
                        
                        questionVC.index = qindex
                        questionVC.email = email
                        questionVC.userName = name
                        questionVC.type = type
                        questionVC.subject = subject
                        questionVC.qnum = Int(item.index)
                        
                        self.present(questionVC, animated: true, completion: nil)
                    }
                    
                }
            }
        
        print("클릭됨 : \(indexPath.row)")
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.answeredToggle.isOn) {
            if (self.type == "student") {
                let item = self.questionAnsweredItems[indexPath.row]
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 완료"
                    cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 완료"
                    cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
                    return cell
                }
            } else {
                let item = self.questionNotAnsweredItems[indexPath.row]
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 대기"
                    cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 대기"
                    cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
                    return cell
                }
            }
        } else {
            let item = self.questionListItems[indexPath.row]
            if (self.type == "student") {
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
                    }
                    return cell
                }
            } else {
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
                    }
                    return cell
                }
            }
        }
    }
}
