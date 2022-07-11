//
//  StudentEvaluationCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class StudentEvaluationCell: UITableViewCell, UITextFieldDelegate {
    let nowDate = Date()
    
    @IBOutlet weak var classColorView: UIView!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var showMoreInfoButton: UIButton!
    @IBOutlet weak var TeacherNameLabel: UILabel! // 선생님 이름 Label
    @IBOutlet weak var isRecorededLabel: UILabel!
    
    var selectedMonth = ""
    var evaluation = ""
    var studentUid = ""
    var teacherName = ""
    var teacherEmail = ""
    var subject = ""
    
    func setStudentUID(_ studentUid: String) {
        self.studentUid = studentUid
    }
    
    func setTeacherInfo(_ teacherName: String, _ teacherEmail: String, _ subject: String) {
        self.teacherName = teacherName
        self.teacherEmail = teacherEmail
        self.subject = subject
        getEvaluation()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        LoadingHUD.isLoaded = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        self.selectedMonth = dateFormatter.string(from: self.nowDate) + "월"
        
        cellBackgroundView.clipsToBounds = true
        cellBackgroundView.layer.cornerRadius = 15
        
        self.selectionStyle = .none
    }
    
    func getEvaluation() {
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                for document in snapshot.documents {
                    if (LoadingHUD.isLoaded == false) {
                        LoadingHUD.show()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            LoadingHUD.isLoaded = true
                            LoadingHUD.hide()
                        }
                    }
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
                                db.collection("student").document(studentUid).collection("class").document(self.teacherName + "(" + self.teacherEmail + ") " + self.subject).collection("Evaluation").whereField("month", isEqualTo: self.selectedMonth).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        self.isRecorededLabel.text = "\(self.selectedMonth)의 평가가 없어요..."
                                        for document in querySnapshot!.documents {
                                            let evaluation = document.data()["evaluation"] as? String ??  "\(self.selectedMonth)의 평가가 없어요..."
                                            self.isRecorededLabel.text = "\(self.selectedMonth)의 평가 등록 완료!"
                                            LoadingHUD.isLoaded = true
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
