//
//  QuestionViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/11.
//

import UIKit
import Kingfisher
import Firebase
import AVFoundation

class QuestionViewController: BaseVC {
    
    // 요소 연결(테이블 뷰 X)
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    
    // 테이블 뷰 연결
    @IBOutlet weak var questionTV: UITableView!
    
    let db = Firestore.firestore()
    var docRef : CollectionReference!
    
    // 값을 넘겨주기 위한 변수들
    var index : Int!
    var email : String!
    var subject : String!
    var userName : String!
    var classColor : String!
    var type = ""       // 유저의 타입
    var questionItems: [QuestionItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    // 상단 유저 정보 가져오기
    func getUserInfo(){

        let db = Firestore.firestore()
        let docRef = db.collection("teacher")
        
        docRef.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러(inQuestionVC) : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inQuestionVC): \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.type = document.data()["type"] as? String ?? ""
                        self.email = document.data()["email"] as? String ?? ""
                        self.userName = document.data()["name"] as? String ?? ""
                        self.setTeacherInfo()
                    }
                }
            }
        }
        
        let docRef2 = db.collection("student")
        docRef2.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let type = document.data()["type"] as? String ?? ""
                        self.type = type
                        let email = document.data()["email"] as? String ?? ""
                        self.setStudentInfo()
                    }
                }
            }
        }
        
    }
    
    /// 선생님 셋팅
    func setTeacherInfo() {
        LoginRepository.shared.doLogin {
            /// 가져오는 시간 걸림
            self.teacherName.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
            self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
            
            let url = URL(string: LoginRepository.shared.teacherItem!.profile)
            //            let url = Auth.auth().currentUser?.photoURL
            self.teacherImage.kf.setImage(with: url)
            self.teacherImage.makeCircle()
            
            /// 클래스 가져오기
            self.setQuestionroom()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    /// 학생 셋팅
    func setStudentInfo() {
        LoginRepository.shared.doLogin {
            /// 가져오는 시간 걸림
            self.teacherName.text = "\(LoginRepository.shared.studentItem!.name) 학생"
            self.teacherEmail.text = LoginRepository.shared.studentItem!.email
            
            /// 클래스 가져오기
            self.setQuestionroom()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    /// 질문방 내용 세팅
    // 내 수업 가져오기
    func setQuestionroom() {
        let db = Firestore.firestore()
        
        // 선생님일 경우
        var docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        docRef.collection("class").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    
                    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                            self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                        } else {
                            /// nil이 아닌지 확인한다.
                            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                
                                return
                            }
                            
                            /// 조회하기 위해 원래 있던 것 들 다 지움
                            self.questionItems.removeAll()
                            
                            
                            for document in snapshot.documents {
                                print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                                
                                /// document.data()를 통해서 값 받아옴, data는 dictionary
                                let classDt = document.data()
                                
                                
                                // self.type = "teacher"
                                // nil 값 처리
                                let name = classDt["name"] as? String ?? ""
                                self.userName = name
                                let subject = classDt["subject"] as? String ?? ""
                                self.subject = subject
                                let classColor = classDt["circleColor"] as? String ?? "026700"
                                let email = classDt["email"] as? String ?? ""
                                self.email = email
                                
                                let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email)
                                
                                /// 모든 값을 더한다.
                                self.questionItems.append(item)
                            }
                            
                            /// UITableView를 reload 하기
                            self.questionTV.reloadData()
                        }
                    }
                    
                    return
                }
                
                /// 조회하기 위해 원래 있던 것 들 다 지움
                self.questionItems.removeAll()
                
                
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let classDt = document.data()
                    
                     
                    //self.type = "student"
                    
                    /// nil값 처리
                    let name = classDt["name"] as? String ?? ""
                    self.userName = name
                    let subject = classDt["subject"] as? String ?? ""
                    self.subject = subject
                    let classColor = classDt["circleColor"] as? String ?? "026700"
                    self.classColor = classColor
                    let email = classDt["email"] as? String ?? ""
                    self.email = email
                    let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email)
                    
                    /// 모든 값을 더한다.
                    self.questionItems.append(item)
                }
                
                /// UITableView를 reload 하기
                self.questionTV.reloadData()
            }
            
            return
            
            
        } /// db.collection("teacher") 끝
    
    
        // 학생일 경우
        docRef = db.collection("student").document(Auth.auth().currentUser!.uid)
        docRef.collection("class").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    
                    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                            self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                        } else {
                            /// nil이 아닌지 확인한다.
                            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                
                                return
                            }
                            
                            /// 조회하기 위해 원래 있던 것 들 다 지움
                            self.questionItems.removeAll()
                            
                            
                            for document in snapshot.documents {
                                print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                                
                                /// document.data()를 통해서 값 받아옴, data는 dictionary
                                let classDt = document.data()
                                
                                
                                // self.type = "teacher"
                                // nil 값 처리
                                let name = classDt["name"] as? String ?? ""
                                self.userName = name
                                let subject = classDt["subject"] as? String ?? ""
                                self.subject = subject
                                let classColor = classDt["circleColor"] as? String ?? "026700"
                                let email = classDt["email"] as? String ?? ""
                                self.email = email
                                let index = classDt["index"] as? Int ?? 0
                                self.index = index
                                
                                let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email)
                                
                                /// 모든 값을 더한다.
                                self.questionItems.append(item)
                            }
                            
                            /// UITableView를 reload 하기
                            self.questionTV.reloadData()
                        }
                    }
                    
                    return
                }
                
                /// 조회하기 위해 원래 있던 것 들 다 지움
                self.questionItems.removeAll()
                
                
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let classDt = document.data()
                    
                     
                    //self.type = "student"
                    
                    /// nil값 처리
                    let name = classDt["name"] as? String ?? ""
                    self.userName = name
                    let subject = classDt["subject"] as? String ?? ""
                    self.subject = subject
                    let classColor = classDt["circleColor"] as? String ?? "026700"
                    self.classColor = classColor
                    let email = classDt["email"] as? String ?? ""
                    self.email = email
                    let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email)
                    
                    /// 모든 값을 더한다.
                    self.questionItems.append(item)
                }
                
                /// UITableView를 reload 하기
                self.questionTV.reloadData()
            }
            
            return
            
            
        }
    
    
    
    }
    
}


// MARK: - 테이블뷰 관련

extension QuestionViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "question")! as! QuestionTableViewCell
        
        let item:QuestionItem = questionItems[indexPath.row]
        if (self.type == "teacher") {
            cell.studentName.text = "\(item.userName) 학생"
        } else {
            cell.studentName.text = "\(item.userName) 선생님"
        }
        cell.subjectName.text = item.subjectName
        //print(item.subjectName)
        cell.classColor.allRoundSmall()
        if let hex = Int(item.classColor, radix: 16) {
            cell.classColor.backgroundColor = UIColor.init(rgb: hex)
        } else {
            cell.classColor.backgroundColor = UIColor.red
        }
        
        return cell
        
    }

    /// didDelectRowAt: 셀 전체 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                    
                    guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionListViewController") as? QuestionListViewController else { return }
                    
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
        
        print("클릭됨 : \(indexPath.row)")
        
//        guard let questionListVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionListViewController") as? QuestionListViewController else { return }
//
//        questionListVC.modalPresentationStyle = .fullScreen
//        questionListVC.modalTransitionStyle = .crossDissolve
//
//        questionListVC.email = email
//        questionListVC.subject = self.subject
//        questionListVC.userName = self.userName
//        questionListVC.type = self.type
//        questionListVC.index = indexPath.row
//
//        self.present(questionListVC, animated: true, completion: nil)
    }
}
