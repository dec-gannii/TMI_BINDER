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
    
    // 뒤로가기 버튼
    @IBOutlet var backbutton: UIView!
    
    @IBAction func clickBackbutton(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    // 토글
    @IBOutlet weak var answeredToggle: UISwitch!
    
    
    // 테이블 뷰 연결
    @IBOutlet weak var questionListTV: UITableView!
    
    weak var delegate: QuestionListViewDelegate?
    
    // 값을 받아오기 위한 변수들
    var userName : String!
    var subject : String!
    var email : String!
    var type = ""
    var index : Int!
    var questionItems: [QuestionItem] = []
    var questionListItems: [QuestionListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answeredToggle.setOn(false, animated: true)
        getUserInfo()
        setQuestionList()
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
                                                print(self.userName + "1")
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
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
                
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let classDt = document.data()
                    
                    /// nil값 처리
                    let title = classDt["title"] as? String ?? ""
                    let answerCheck = classDt["answerCheck"] as? Bool ?? false
                    let questionContent = classDt["questionContent"] as? String ?? ""
                    let imgURL = classDt["imgURL"] as? String ?? ""
                    let email = classDt["email"] as? String ?? ""
                    let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL , questionContent: questionContent, email: email as! String)
                    
                    
                    /// 모든 값을 더한다.
                    self.questionListItems.append(item)
                }
                
                /// UITableView를 reload 하기
                self.questionListTV.reloadData()
            }
        }
    }
}




// MARK: - 테이블 뷰 관련

extension QuestionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return questionListItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item:QuestionListItem = questionListItems[indexPath.row]
        
        if item.imgURL == "" {     // 기본 셀일 경우
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
            cell.title.text = "\(item.title)"
            cell.questionContent.text = "\(item.questionContent)"
            
            if item.answerCheck == false {
                cell.answerCheck.text = "답변 대기"
                cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
            } else {
                cell.answerCheck.text = "답변 완료"
                cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
            }
            
            return cell
            
        } else {       // 이미지 셀일 경우
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
            
            cell.title.text = "\(item.title)"
            cell.questionContent.text = "\(item.questionContent)"
            
            let url = URL(string: item.imgURL)
            cell.questionImage.kf.setImage(with: url, placeholder: UIImage(systemName: "questionImage.fill"), options: nil, completionHandler: nil)
            
            if item.answerCheck == false {
                cell.answerCheck.text = "답변 대기"
                cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
            } else {
                cell.answerCheck.text = "답변 완료"
                cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
            }
            
            return cell
        }
    }
}
