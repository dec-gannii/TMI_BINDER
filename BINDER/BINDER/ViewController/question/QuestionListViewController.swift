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
    
    @IBAction func clickBackbutton(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    // 토글
    @IBOutlet weak var answeredToggle: UISwitch!
    
    @IBAction func answeredToggleAction(_ sender: Any) {
        setQuestionList()
        questionListTV.reloadData()
    }
    // 테이블 뷰 연결
    @IBOutlet weak var questionListTV: UITableView!
    
    
    // 값을 받아오기 위한 변수들
    var userName : String!
    var subject : String!
    var email : String!
    var answerCheck : Bool!
    var type = ""
    var index : Int!
    var teacherUid: String!
    var questionListItems : [QuestionListItem] = []
    var questionAnsweredItems : [QuestionAnsweredListItem] = []
    var questionNotAnsweredItems : [QuestionAnsweredListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answeredToggle.setOn(false, animated: true)
        getUserInfo()
        
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
                                                    self.questionListTV.reloadData()
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
    
    // 나중에 갈라질 건데, 선생님일 경우에는 질문 답변하기 버튼 위에 나타내고, 학생일 경우에는 플러스 버튼으로 질문하기 나타내도록
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
        // Auth.auth().currentUser!.uid
        //db.collection("student").getDocuments(){ (querySnapshot, err) in
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
                        let index = questionDt["index"] as? String ?? ""
                        let title = questionDt["title"] as? String ?? ""
                        let answerCheck = questionDt["answerCheck"] as? Bool ?? false
                        let questionContent = questionDt["questionContent"] as? String ?? ""
                        let imgURL = questionDt["imgURL"] as? String ?? ""
                        let email = questionDt["email"] as? String ?? ""
                        
                        let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL , questionContent: questionContent, email: email, index: index )
                        
                        let answeredItem = QuestionAnsweredListItem(title: title, answerCheck: answerCheck, imgURL: imgURL, questionContent: questionContent, email: email, index: index)
                        
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
            if let email = self.email {
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
                        }
                        
                        db.collection("teacher").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
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
                                }
                                
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
                                            print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                                            
                                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                                            let questionDt = document.data()
                                            
                                            /// nil값 처리
                                            let index = questionDt["index"] as? String ?? ""
                                            let title = questionDt["title"] as? String ?? ""
                                            let answerCheck = questionDt["answerCheck"] as? Bool ?? false
                                            let questionContent = questionDt["questionContent"] as? String ?? ""
                                            let imgURL = questionDt["imgURL"] as? String ?? ""
                                            let email = questionDt["email"] as? String ?? ""
                                            
                                            let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL , questionContent: questionContent, email: email, index: index )
                                            
                                            let answeredItem = QuestionAnsweredListItem(title: title, answerCheck: answerCheck, imgURL: imgURL, questionContent: questionContent, email: email, index: index)
                                            
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
        
        var index: Int!
        var name: String!
        var email: String!
        var subject: String!
        var type: String!
        
        docRef.document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: indexPath.row)
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
                        
                        index = questionDt["index"] as? Int ?? 0
                        name = questionDt["name"] as? String ?? ""
                        subject = questionDt["subject"] as? String ?? ""
                        email = questionDt["email"] as? String ?? ""
                        type = questionDt["type"] as? String ?? ""
                        
                        qnaVC.index = index
                        qnaVC.email = email
                        qnaVC.userName = name
                        qnaVC.type = type
                        qnaVC.subject = subject
                        
                        self.present(qnaVC, animated: true, completion: nil)
                    }
                    else { // 답변이 없는 경우
                        guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionDetailVC") as? QuestionDetailViewController else { return }
                        
                        questionVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        questionVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                        /// first : 여러개가 와도 첫번째 것만 봄.
                        
                        let questionDt = snapshot.documents.first!.data()
                        
                        index = questionDt["index"] as? Int ?? 0
                        name = questionDt["name"] as? String ?? ""
                        subject = questionDt["subject"] as? String ?? ""
                        email = questionDt["email"] as? String ?? ""
                        type = questionDt["type"] as? String ?? ""
                        
                        questionVC.index = index
                        questionVC.email = email
                        questionVC.userName = name
                        questionVC.type = type
                        questionVC.subject = subject
                        
                        self.present(questionVC, animated: true, completion: nil)
                    }
                    
                }
            }
        
        print("클릭됨 : \(indexPath.row)")
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let item:QuestionListItem = self.questionListItems[indexPath.row]
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
                    cell.title.text = self.questionAnsweredItems[indexPath.row].title
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
