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
    
    // 네비게이션바
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toggleLabel: UILabel!
    
    // 뒤로가기 버튼
    @IBOutlet var backbutton: UIView!
    
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
                        
                        if let email = self.email { // 사용자의 이메일이 nil이 아니라면
                            // 선생님들 정보의 경로 중 이메일이 일치하는 선생님 찾기
                            teacherDocRef.whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let teacherUid = document.data()["uid"] as? String ?? ""
                                        
                                        // 선생님의 수업 목록 중 학생과 일치하는 정보 불러오기
                                        self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").getDocuments() {(document, error) in
                                            
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
        
        return
    }
}




// MARK: - 테이블 뷰 관련

extension QuestionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if answeredToggle.isOn{
            if (self.type == "teacher") {
                return self.questionNotAnsweredItems.count
            } else {
                return self.questionAnsweredItems.count
            }
        }
        else {
            return self.questionListItems.count
        }
        
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
