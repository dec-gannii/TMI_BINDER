//
//  QuestionDetailViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2022/03/01.
//

import UIKit
import Kingfisher
import Firebase

class QuestionDetailViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var questionContent: UITextView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var answerBtn: UIButton!
    
    // 값을 받아오기 위한 변수들
    var userName : String!
    var subject : String!
    var email : String!
    var type = ""
    var index : Int!
    var qnum: Int!
    var teacherUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    @IBAction func undoBtn(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func clickanswerBtn(_ sender: Any) {
        guard let answerVC = self.storyboard?.instantiateViewController(withIdentifier: "AnswerVC") as? AnswerViewController else { return }
        
        answerVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        answerVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        /// first : 여러개가 와도 첫번째 것만 봄.
        
        answerVC.index = index
        answerVC.qnum = qnum
        answerVC.email = email
        answerVC.userName = userName
        answerVC.type = type
        answerVC.subject = subject
        
        self.present(answerVC, animated: true, completion: nil)
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
                                                
                                                self.setQuestion()
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
                                                    self.setQuestion()
//                                                    self.answerBtn.isEnabled = false
                                                    self.answerBtn.removeFromSuperview()
                                                    self.answerBtn.backgroundColor = .white
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
    
    
    // 질문 리스트 가져오기
    func setQuestion() {
        let db = Firestore.firestore()
        if (self.type == "teacher") {
            if let qnum = self.qnum {
                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").whereField("num", isEqualTo: String(qnum)).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                        
                    } else {
                        /// nil이 아닌지 확인한다.
                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                            return
                        }
                        
                        for document in snapshot.documents {
                            print(">>>>> 자세한 document 정보 : \(document.documentID) => \(document.data())")
                            
                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                            let questionDt = document.data()
                            /// nil값 처리
                            let title = questionDt["title"] as? String ?? ""
                            let questionContent = questionDt["questionContent"] as? String ?? ""
                            let imgURL = questionDt["imgURL"] as? String ?? ""
                            
                            self.titleName.text = title
                            self.questionContent.text = questionContent
                            if imgURL != "" {
                                let url = URL(string: imgURL)
                                DispatchQueue.global().async {
                                    let data = try? Data(contentsOf: url!)
                                    DispatchQueue.main.async {
                                        self.imgView.image = UIImage(data: data!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if let email = self.email, let index = self.index {
                var studentName = ""
                var studentEmail = ""
                var teacherUid = ""
                
                db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                        
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
                                            
                                        } else {
                                            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                return
                                            }
                                            
                                            for document in querySnapshot!.documents {
                                                teacherUid = document.data()["uid"] as? String ?? ""
                                                self.teacherUid = teacherUid
                                                print ("TeacherUID : \(teacherUid)")
                                                
                                                db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").whereField("num", isEqualTo: String(self.qnum)).getDocuments() { (querySnapshot, err) in
                                                    if let err = err {
                                                        print(">>>>> document 에러 : \(err)")
                                                    } else {
                                                        /// nil이 아닌지 확인한다.
                                                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                            return
                                                        }
                                                        
                                                        for document in snapshot.documents {
                                                            print(">>>>> 자세한 document 정보 : \(document.documentID) => \(document.data())")
                                                            
                                                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                            let questionDt = document.data()
                                                            /// nil값 처리
                                                            let title = questionDt["title"] as? String ?? ""
                                                            let questionContent = questionDt["questionContent"] as? String ?? ""
                                                            let imgURL = questionDt["imgURL"] as? String ?? ""
                                                            
                                                            self.titleName.text = title
                                                            self.questionContent.text = questionContent
                                                            if imgURL != "" {
                                                                let url = URL(string: imgURL)
                                                                DispatchQueue.global().async {
                                                                    let data = try? Data(contentsOf: url!)
                                                                    DispatchQueue.main.async {
                                                                        self.imgView.image = UIImage(data: data!)
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
                    }
                }
            }
        }
        return
    }
}
