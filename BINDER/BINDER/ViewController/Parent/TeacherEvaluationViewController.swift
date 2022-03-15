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
    //    var index: Int = 0
    var month: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        self.TeacherTitle.text = self.teacherName + " 선생님의 " + self.month + " 수업은..."
    }
    
    func getUserInfo() {
//        self.db.collection("parent").document("teacherEvaluation").collection(self.teacherName + "(" + self.teacherEmail + ")").document(self.month).setData([
//            "teacherAttitude": teacherAttitude.text!,
//            "teacherManagingSatisfyScore": teacherManagingSatisfyScore.text!
//        ])
//        { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            }
//        }
        
            self.db.collection("parent").document(Auth.auth().currentUser!.uid).collection("teacherEvaluation").document(self.teacherName + "(" + self.teacherEmail + ")").collection(self.month).document("evaluation").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let teacherAttitude = data!["teacherAttitude"] as? String ?? ""
                let teacherManagingSatisfyScore = data!["teacherManagingSatisfyScore"] as? String ?? ""
                self.teacherAttitude.text = teacherAttitude
                self.teacherManagingSatisfyScore.text = teacherManagingSatisfyScore
            }
        }
        
        self.db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let childPhoneNumber = data!["childPhoneNumber"] as? String ?? ""
                self.db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let studentUid = document.data()["uid"] as? String ?? ""
                            //                            let studentEmail = document.data()["email"] as? String ?? ""
                                                        let studentName = document.data()["name"] as? String ?? ""
                            self.studentTitle.text = studentName + " 학생의 " + self.month + " 수업은..."
                            //
                            //                            self.db.collection("student").document(studentUid).collection("class").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
                            //                                if let err = err {
                            //                                    print("Error getting documents: \(err)")
                            //                                } else {
                            //                                    for document in querySnapshot!.documents {
                            //                                        print("\(document.documentID) => \(document.data())")
                            //                                        // 사용할 것들 가져와서 지역 변수로 저장
                            //                                        self.db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
                            //                                            if let err = err {
                            //                                                print("Error getting documents: \(err)")
                            //                                            } else {
                            //                                                for document in querySnapshot!.documents {
                            //                                                    print("\(document.documentID) => \(document.data())")
                            //                                                    let teacherUid = document.data()["uid"] as? String ?? ""
                            //
                            //                                                    self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("Evaluation").whereField("email", isEqualTo: studentEmail).getDocuments() { (querySnapshot, err) in
                            //                                                        if let err = err {
                            //                                                            print("Error getting documents: \(err)")
                            //                                                        } else {
                            //                                                            for document in querySnapshot!.documents {
                            //                                                                print("\(document.documentID) => \(document.data())")
                            //                                                                // 사용할 것들 가져와서 지역 변수로 저장
                            //                                                                // 여기서 이제 평균 점수 내는 거 고려해야 함
                            //                                                            }
                            //                                                        }
                            //                                                    }
                            //                                                }
                            //                                            }
                            //                                        }
                            //                                    }
                            //                                }
                            //                            }
                            
                            
                            self.db.collection("student").document(studentUid).collection("class").document(self.teacherName + "(" + self.teacherEmail + ") " + self.subject).collection("Evaluation").whereField("month", isEqualTo: self.month).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let evaluationData = document.data()
                                        
                                        let evaluation = evaluationData["evaluation"] as? String ?? ""
                                        self.evaluationTextView.text = evaluation
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
    }
    
    @IBAction func SaveTeacherEvaluation(_ sender: Any) {
            self.db.collection("parent").document(Auth.auth().currentUser!.uid).collection("teacherEvaluation").document(self.teacherName + "(" + self.teacherEmail + ")").collection(self.month).document("evaluation").setData([
            "teacherAttitude": teacherAttitude.text!,
            "teacherManagingSatisfyScore": teacherManagingSatisfyScore.text!
        ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
