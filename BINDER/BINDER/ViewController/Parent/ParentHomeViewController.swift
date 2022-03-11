//
//  ParentHomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseFirestore

class ParentHomeViewController: UIViewController {
    var evaluationItem: [EvaluationItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
//        setEvaluation()
        progressListTableView.delegate = self
        progressListTableView.dataSource = self
    }
    
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var progressListTableView: UITableView!
    
    func getUserInfo() {
        let db = Firestore.firestore()
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let name = document.data()["name"] as? String ?? ""
                        self.parentNameLabel.text = name + " 학부모님"
                    }
                }
            }
        }
    }
    
    func setEvaluation() {
        let db = Firestore.firestore()
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    /// nil값 처리
                    let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                    db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let studentUid = document.data()["uid"] as? String ?? ""
                                let studentName = document.data()["name"] as? String ?? ""
                                
                                print ("studentName : \(studentName), studentUid : \(studentUid)")
                                
                                // path가 문제있음
                                db.document("student").collection(studentUid).whereField("totalCnt", isEqualTo: 8).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        print("===6===")
                                        for document in querySnapshot!.documents {
                                            print("===7===")
                                            let evaluationData = document.data()
                                            
                                            let name = evaluationData["name"] as? String ?? "" // 선생님 이름
                                            let email = evaluationData["email"] as? String ?? "" // 선생님 이메일
                                            let subject = evaluationData["subject"] as? String ?? "" // 과목
                                            let currentCnt = evaluationData["currentCnt"] as? Int ?? 0 // 현재 횟수
                                            let totalCnt = evaluationData["totalCnt"] as? Int ?? 8 // 총 횟수
                                            let evaluation = evaluationData["evaluation"] as? String ?? "평가 기본 항목입니다." // 평가 내용
                                            let circleColor = evaluationData["circleColor"] as? String ?? "026700" // 원 색상
                                            let item = EvaluationItem(email: email, name: name, evaluation: evaluation, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: circleColor, subject: subject)
                                            self.evaluationItem.append(item)
                                            print ("evaluationItem => \(self.evaluationItem)")
                                        }
                                    }
                                }
                            }
                        }
                        //                        }
                        print("===8===")
                        /// UITableView를 reload 하기
                        self.progressListTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension ParentHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return evaluationItem.count
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentEvaluationCell", for: indexPath) as! StudentEvaluationCell

        // 하드코딩
        cell.subjectLabel.text = "국어"
        cell.progressLabel.text = "40%"
        cell.monthlyEvaluationTextView.text = "이번 한 달 간 현수가 열심히 따라와주어서 국어 성적이 조금이나마 오른 것 같습니다~~~"
        cell.classColorView.makeCircle()
        if let hex = Int("026700", radix: 16) {
            cell.classColorView.backgroundColor = UIColor.init(rgb: hex)
        } else {
            cell.classColorView.backgroundColor = UIColor.red
        }
        
//        cell.showMoreInfoButton.addTarget(self, action: #selector(onClickManageButton(_:)), for: .touchUpInside)
        cell.showMoreInfoButton.tag = indexPath.row
        
        return cell
    }
    
}
