//
//  TeacherEvaluationViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/15.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class TeacherEvaluationViewController: UIViewController {
    let db = Firestore.firestore()
    
    @IBOutlet var studentTitle: UILabel!
    @IBOutlet var TeacherTitle: UILabel!
    @IBOutlet var averageHomeworkCompletion: UILabel!
    @IBOutlet var averageClassAttitude: UILabel!
    @IBOutlet var averageTestScore: UILabel!
    @IBOutlet var evaluationTextView: UITextView!
    @IBOutlet var teacherAttitude: UITextField!
    @IBOutlet var teacherManagingSatisfyScore: UITextField!
    
    var teacherName: String = ""
    var teacherEmail: String = ""
    var subject: String = ""
    var month: String = ""
    var date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        evaluationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.TeacherTitle.text = self.teacherName + " 선생님의 " + self.month + " 수업은..." // 선생님 평가 title 설정
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo() // 사용자 정보 가져오기
        getEvaluation() // 학생에 대한 평가 정보 가져오기
    }
    
    /// 사용자 정보 가져오기
    func getUserInfo() {
        /// parent collection / 현재 사용자 uid / teacherEvaluation collection / 선생님이름(선생님이메일) 과목 / evaluation 경로에서 문서 찾기
        self.db.collection("parent").document(Auth.auth().currentUser!.uid).collection("teacherEvaluation").document(self.teacherName + "(" + self.teacherEmail + ")").collection(self.month).document("evaluation").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let teacherAttitude = data!["teacherAttitude"] as? String ?? "" // 선생님 태도 점수
                let teacherManagingSatisfyScore = data!["teacherManagingSatisfyScore"] as? String ?? "" // 학생 관리 만족도 점수
                self.teacherAttitude.text = teacherAttitude // 선생님 태도 점수 text 지정
                self.teacherManagingSatisfyScore.text = teacherManagingSatisfyScore // 학생 관리 만족도 점수 지정
            }
        }
        
        /// parent collection / 현재 사용자 uid 경로에서 문서 찾기
        self.db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists { /// 문서 있으면
                let data = document.data()
                let childPhoneNumber = data!["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
                ///  student collection에 가져온 학생 전화번호와 동일한 전화번호 정보를 가지는 문서 찾기
                self.db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        /// 문서 있으면
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let studentName = document.data()["name"] as? String ?? "" // 학생 이름
                            self.studentTitle.text = studentName + " 학생의 " + self.date + " 수업은..." // 학생 평가 title text 설정
                            
                            self.evaluationTextView.isEditable = false // 평가 textview 수정 못하도록 설정
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getEvaluation(){
        // 데이터베이스 경로
        self.db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                    
                    let parentDocRef = self.db.collection("parent")
                    parentDocRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                                
                                let docRef = self.db.collection("student")
                                docRef.whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            let studentEmail = document.data()["email"] as? String ?? "" // 학생 이메일
                                            let studentName = document.data()["name"] as? String ?? "" // 학생 이메일
                                            
                                            self.db.collection("teacher").document(teacherUid).collection("class").whereField("email", isEqualTo: studentEmail).getDocuments() { (querySnapshot, err) in
                                                if let err = err {
                                                    print(">>>>> document 에러 : \(err)")
                                                } else {
                                                    for document in querySnapshot!.documents {
                                                        print("\(document.documentID) => \(document.data())")
                                                        let subject = document.data()["subject"] as? String ?? ""
                                                        
                                                        self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + subject).collection("Evaluation").whereField("evaluationDate", isEqualTo: self.date).getDocuments() { (querySnapshot, err) in
                                                            if let err = err {
                                                                print("Error getting documents: \(err)")
                                                            } else {
                                                                for document in querySnapshot!.documents {
                                                                    print("\(document.documentID) => \(document.data())")
                                                                    // 사용할 것들 가져와서 지역 변수로 저장
                                                                    let evaluationMemo = document.data()["evaluationMemo"] as? String ?? "선택된 날짜에는 수업이 없었습니다."
                                                                    self.evaluationTextView.text = evaluationMemo
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
    
    /// 선생님 평가 저장 버튼 클릭 시 실행되는 메소드
    @IBAction func SaveTeacherEvaluation(_ sender: Any) {
        /// parent collection / 현재 사용자 Uid / teacherEvaluation / 선생님이름(선생님이메일) / 현재 달 collection / evaluation 아래에 선생님 태도 점수와 학생 관리 만족도 점수 저장
        self.db.collection("parent").document(Auth.auth().currentUser!.uid).collection("teacherEvaluation").document(self.teacherName + "(" + self.teacherEmail + ")").collection(self.month).document("evaluation").setData([
            "teacherAttitude": teacherAttitude.text!,
            "teacherManagingSatisfyScore": teacherManagingSatisfyScore.text!
        ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        // modal dismiss
        self.dismiss(animated: true, completion: nil)
    }
}
