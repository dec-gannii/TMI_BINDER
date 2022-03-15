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
    var studentUid: String = ""
    var teacherName = ""
    var teacherEmail = ""
    var subject = ""
    var selectedMonth = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        //        setEvaluation()
        progressListTableView.delegate = self
        progressListTableView.dataSource = self
        progressListTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        progressListTableView.reloadData()
    }
    
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var progressListTableView: UITableView!
    //    @IBOutlet weak var monthPickerView: UITextField!
    
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
        setEvaluation()
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
                                self.studentUid = studentUid
                                // path가 문제있음
                                db.collection("student").document(studentUid).collection("class").whereField("totalCnt", isEqualTo: 8).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        /// 조회하기 위해 원래 있던 것 들 다 지움
                                        self.evaluationItem.removeAll()
                                        
                                        for document in querySnapshot!.documents {
                                            let evaluationData = document.data()
                                            
                                            let name = evaluationData["name"] as? String ?? "" // 선생님 이름
                                            self.teacherName = name
                                            let email = evaluationData["email"] as? String ?? "" // 선생님 이메일
                                            self.teacherEmail = email
                                            let subject = evaluationData["subject"] as? String ?? "" // 과목
                                            self.subject = subject
                                            let currentCnt = evaluationData["currentCnt"] as? Int ?? 0 // 현재 횟수
                                            let totalCnt = evaluationData["totalCnt"] as? Int ?? 8 // 총 횟수
                                            var evaluation = evaluationData["evaluation"] as? String ?? "선택된 달이 없습니다." // 평가 내용
                                            let circleColor = evaluationData["circleColor"] as? String ?? "026700" // 원 색상
                                            
                                            let item = EvaluationItem(email: email, name: name, evaluation: evaluation, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: circleColor, subject: subject)
                                            self.evaluationItem.append(item)
                                            print ("evaluationItem => \(self.evaluationItem)")
                                        }
                                    }
                                }
                            }
                        }
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
        return evaluationItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentEvaluationCell", for: indexPath) as! StudentEvaluationCell
        cell.studentUid = self.studentUid
        
        let item:EvaluationItem = evaluationItem[indexPath.row]
        
        cell.setTeacherInfo(item.name, item.email, item.subject)
        
        cell.subjectLabel.text = item.subject + " - " + item.name + " 선생님"
        cell.progressLabel.text = "\(item.currentCnt) / \(item.totalCnt)"
        cell.monthlyEvaluationTextView.text = item.evaluation
        cell.classColorView.makeCircle()
        if let hex = Int(item.circleColor, radix: 16) {
            cell.classColorView.backgroundColor = UIColor.init(rgb: hex)
        } else {
            cell.classColorView.backgroundColor = UIColor.red
        }
        
        cell.showMoreInfoButton.addTarget(self, action: #selector(onClickShowDetailButton(_:)), for: .touchUpInside)
        cell.showMoreInfoButton.tag = indexPath.row
        
        self.selectedMonth = cell.selectedMonth
    
        return cell
    }
    
    @IBAction func onClickShowDetailButton(_ sender: UIButton) {

        guard let detailEvaluationVC = self.storyboard?.instantiateViewController(withIdentifier: "ParentDetailEvaluationViewController") as? ParentDetailEvaluationViewController else {
            //아니면 종료
            return
        }
        detailEvaluationVC.modalTransitionStyle = .crossDissolve
        detailEvaluationVC.modalPresentationStyle = .fullScreen

        detailEvaluationVC.teacherName = self.teacherName
        detailEvaluationVC.teacherEmail = self.teacherEmail
        detailEvaluationVC.subject = self.subject
        detailEvaluationVC.index = sender.tag
        detailEvaluationVC.month = self.selectedMonth

        self.present(detailEvaluationVC, animated: true)
        print("클릭됨 : \(sender.tag)")
    }
}
