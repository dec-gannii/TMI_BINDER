//
//  MyClassVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

struct MyClassDBFunctions {
    var functionShare = FunctionShare()
    
    func GetUserInfoForClassList(self : MyClassVC) {
        db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let type = data["type"] as? String ?? ""
                        self.type = type
                        self.setTeacherInfo()
                        functionShare.LoadingShow(sec: 1.0)
                    }
                }
            }
        }
        
        db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let type = data["type"] as? String ?? ""
                        self.type = type
                        self.setStudentInfo()
                        functionShare.LoadingShow(sec: 1.0)
                    }
                }
            }
        }
    }
    
    func SetMyClasses(self : MyClassVC) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                            self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                        } else {
                            /// nil이 아닌지 확인한다.
                            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                return
                            }
                            
                            /// 조회하기 위해 원래 있던 것 들 다 지움
                            self.classItems.removeAll()
                            
                            for document in snapshot.documents {
                                print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                                
                                /// document.data()를 통해서 값 받아옴, data는 dictionary
                                let classDt = document.data()
                                
                                self.type = "student"
                                /// nil값 처리
                                let email = classDt["email"] as? String ?? ""
                                let name = classDt["name"] as? String ?? ""
                                let goal = classDt["goal"] as? String ?? ""
                                let subject = classDt["subject"] as? String ?? ""
                                let currentCnt = classDt["currentCnt"] as? Int ?? 0
                                let totalCnt = classDt["totalCnt"] as? Int ?? 0
                                let classColor = classDt["circleColor"] as? String ?? "026700"
                                let recentDate = classDt["recentDate"] as? String ?? "최근 수업 날짜가 없습니다."
                                let payType = classDt["payType"] as? String ?? ""
                                let payDate = classDt["payDate"] as? String ?? ""
                                let payAmount = classDt["payAmount"] as? String ?? ""
                                let schedule = classDt["schedule"] as? String ?? ""
                                let repeatYN = classDt["repeatYN"] as? String ?? ""
                                let index = classDt["index"] as? Int ?? 0
                                
                                self.studentEmail = email
                                
                                let item = ClassItem(email: email, name: name, goal: goal, subject: subject, recentDate: recentDate, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: classColor, payType: payType, payDate: payDate, payAmount: payAmount, schedule: schedule, repeatYN: repeatYN, index: index)
                                
                                /// 모든 값을 더한다.
                                self.classItems.append(item)
                            }
                            
                            /// UITableView를 reload 하기
                            self.studentTV.reloadData()
                        }
                    }
                    return
                }
                /// 조회하기 위해 원래 있던 것 들 다 지움
                self.classItems.removeAll()
                
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let classDt = document.data()
                    
                    self.type = "teacher"
                    /// nil값 처리
                    let email = classDt["email"] as? String ?? ""
                    let name = classDt["name"] as? String ?? ""
                    let goal = classDt["goal"] as? String ?? ""
                    let subject = classDt["subject"] as? String ?? ""
                    let currentCnt = classDt["currentCnt"] as? Int ?? 0
                    let totalCnt = classDt["totalCnt"] as? Int ?? 0
                    let classColor = classDt["circleColor"] as? String ?? "026700"
                    let recentDate = classDt["recentDate"] as? String ?? "최근 수업 날짜가 없습니다."
                    let payType = classDt["payType"] as? String ?? ""
                    let payDate = classDt["payDate"] as? String ?? ""
                    let payAmount = classDt["payAmount"] as? String ?? ""
                    let schedule = classDt["schedule"] as? String ?? ""
                    let repeatYN = classDt["repeatYN"] as? String ?? ""
                    let index = classDt["index"] as? Int ?? 0
                    
                    let item = ClassItem(email: email, name: name, goal: goal, subject: subject, recentDate: recentDate, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: classColor, payType: payType, payDate: payDate, payAmount: payAmount, schedule: schedule, repeatYN: repeatYN, index: index)
                    
                    /// 모든 값을 더한다.
                    self.classItems.append(item)
                }
                
                /// UITableView를 reload 하기
                self.studentTV.reloadData()
            }
        }
    }
    
    func MoveToDetailClassVC (self : MyClassVC, sender : UIButton) {
        var index: Int!
        var name: String!
        var email: String!
        var subject: String!
        var type: String!
        
        /// 입력한 이메일과 갖고있는 이메일이 같은지 확인
        var docRef: CollectionReference
        if (self.type == "teacher") {
            docRef = db.collection("teacher")
        } else {
            docRef = db.collection("student")
        }
        
        docRef.document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: sender.tag)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    
                    guard let weekendVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassDetailViewController") as? MyClassDetailViewController else { return }
                    
                    weekendVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                    weekendVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                    /// first : 여러개가 와도 첫번째 것만 봄.
                    
                    let studentDt = snapshot.documents.first!.data()
                    
                    if (self.type == "teacher") {
                        index = studentDt["index"] as? Int ?? 0
                        name = studentDt["name"] as? String ?? ""
                        subject = studentDt["subject"] as? String ?? ""
                        type = "teacher"
                    } else if (self.type == "student") {
                        let teacherDt = snapshot.documents.first!.data()
                        index = teacherDt["index"] as? Int ?? 0
                        name = teacherDt["name"] as? String ?? ""
                        type = "student"
                        subject = teacherDt["subject"] as? String ?? ""
                    }
                    email = studentDt["email"] as? String ?? ""
                    
                    weekendVC.userIndex = index
                    weekendVC.userEmail = email
                    weekendVC.userName = name
                    weekendVC.userType = type
                    weekendVC.userSubject = subject
                    
                    self.present(weekendVC, animated: true, completion: nil)
                }
            }
    }
    
    func SearchStudent(self : AddStudentVC, email : String) {
        /// 입력한 이메일과 갖고있는 이메일이 같은지 확인
        db.collection("student").whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                    self.showDefaultAlert(msg: "학생을 찾는 중 에러가 발생했습니다.")
                } else {
                    
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        self.showDefaultAlert(msg: "해당하는 학생이 존재하지 않습니다.")
                        return
                    }
                    
                    /// first : 여러개가 와도 첫번째 것만 봄.
                    let studentDt = snapshot.documents.first!.data()
                    let age = studentDt["age"] as? Int ?? 0
                    let email = studentDt["email"] as? String ?? ""
                    let goal = studentDt["goal"] as? String ?? ""
                    let name = studentDt["name"] as? String ?? ""
                    let password = studentDt["password"] as? String ?? ""
                    let phone = studentDt["phone"] as? String ?? ""
                    let profile = studentDt["profile"] as? String ?? ""
                    let type = studentDt["type"] as? String ?? ""
                    let uid = studentDt["uid"] as? String ?? ""
                    
                    let item = StudentItem(email: email, goal: goal, name: name, password: password, phone: phone, profile: profile, type: type, uid: uid)
                    
                    /// 값 넘어가기
                    self.performSegue(withIdentifier: "inputClassSegue", sender: item)
                }
                /// 변수 다시 공백으로 바꾸기
                self.emailTf.text = ""
            }
    }
    
    func GetStudentClassCount(self : ClassInfoVC, uid : String) {
        self.studentCount = 0
        db.collection("student").document(uid).collection("class").getDocuments()
        {
            (querySnapshot, err) in
            
            if let err = err
            { print("Error getting documents: \(err)") }
            else
            {
                var count = 0
                for document in querySnapshot!.documents {
                    count += 1
                    print("student \(document.documentID) => \(document.data())");
                }
                if (count > 0) {
                    db.collection("student").document(uid).collection("class").document("\(LoginRepository.shared.teacherItem!.name)(\(LoginRepository.shared.teacherItem!.email)) " + self.subjectTextField.text!).updateData(["index": count-1])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                }
            }
        }
    }
    
    func GetTeacherClassCount(self : ClassInfoVC) {
        self.studentCount = 0
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments()
        {
            (querySnapshot, err) in
            
            if let err = err
            { print("Error getting documents: \(err)") }
            else
            {
                var count = 0
                
                for document in querySnapshot!.documents {
                    count += 1
                    print("\(document.documentID) => \(document.data())");
                }
                if (count > 0) {
                    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.studentItem.name + "(" + self.studentItem.email + ") " + self.subjectTextField.text!).updateData(["index": count-1])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                    
                }
            }
        }
    }
    
    func SaveClassInfo(self : ClassInfoVC, subject : String, payDate : String, payment : String , schedule : String) {
        // 데이터베이스 연결
        var studentUid = ""
        
        db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments {
            (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    db.collection("student").whereField("email", isEqualTo: "\(self.studentItem.email)").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let data = document.data()
                                    studentUid = data["uid"] as? String ?? ""
                                    
                                    db.collection("student").document(studentUid).collection("class").document("\(LoginRepository.shared.teacherItem!.name)(\(LoginRepository.shared.teacherItem!.email)) " + self.subjectTextField.text!).setData([
                                        "email" : "\(LoginRepository.shared.teacherItem!.email)",
                                        "name" : "\(LoginRepository.shared.teacherItem!.name)",
                                        "subject" : self.subjectTextField.text!,
                                        "currentCnt" : 0,
                                        "totalCnt" : 8,
                                        "circleColor" : self.classColor1,
                                        "recentDate" : Date(),
                                        "datetime": Date().formatted(),
                                        "goal": self.studentItem.goal])
                                    { err in
                                        if let err = err {
                                            print(">>>>> document 에러 : \(err)")
                                            self.showDefaultAlert(msg: "수업 저장 중에 에러가 발생했습니다.")
                                        }
                                    }
                                }
                                GetStudentClassCount(self: self, uid: studentUid)
                            }
                        }
                    }
                }
            }
        }
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.studentItem.name + "(" + self.studentItem.email + ") " + self.subjectTextField.text!).setData([
            "email" : self.studentItem.email,
            "name" : self.studentItem.name,
            "goal" : self.studentItem.goal,
            "subject" : subject,
            "currentCnt" : 0,
            "totalCnt" : 8,
            "circleColor" : self.classColor1,
            "recentDate" : "",
            "payType" : self.payType == .timly ? "T" : "C",
            "payDate": payDate,
            "payAmount": payment,
            "schedule" : schedule,
            "repeatYN": self.isRepeat.isOn,
            "datetime": Date().formatted()])
        { err in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "수업 저장 중에 에러가 발생했습니다.")
            } else {
                // 데이타 저장에 성공한 경우 처리
                ///  dissmiss 닫음
                /// completion :클로저
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                    self.delegate?.onSuccess()
                })
            }
        }
    }
    
    func UpdateClassInfo(self : EditClassVC, schedule : String) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
            "subject": self.subjectTF.text ?? "None",
            "payType": self.payType == .timly ? "T" : "C",
            "payAmount": self.payAmountTF.text ?? "None",
            "payDate": self.payDateTF.text ?? "None",
            "repeatYN": self.repeatYN ,
            "schedule": schedule
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func GetClassInfo(self : EditClassVC) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let subject = data?["subject"] as? String ?? ""
                self.subjectTF.text = subject
                
                let payType = data?["payType"] as? String ?? ""
                if (payType == "C") {
                    self.payTypeBtn.setTitle("회차별", for: .normal)
                } else {
                    self.payTypeBtn.setTitle("시간별", for: .normal)
                }
                
                let payAmount = data?["payAmount"] as? String ?? ""
                self.payAmountTF.text = payAmount
                
                let payDate = data?["payDate"] as? String ?? ""
                self.payDateTF.text = payDate
                
                let repeatYN = data?["repeatYN"] as? Bool ?? true
                if (repeatYN == true) {
                    self.repeatYNToggle.setOn(true, animated: true)
                } else {
                    self.repeatYNToggle.setOn(false, animated: true)
                }
                
                let schedule = data?["schedule"] as? String ?? ""
                // 저장된 스케줄을 " " 단위로 갈라내어 배열로 저장함
                self.days = schedule.components(separatedBy: " ")
                print(self.days)
                
                if self.days.contains("월") {
                    self.daysBtn[0].isSelected = true
                }
                if self.days.contains("화") {
                    self.daysBtn[1].isSelected = true
                }
                if self.days.contains("수") {
                    self.daysBtn[2].isSelected = true
                }
                if self.days.contains("목") {
                    self.daysBtn[3].isSelected = true
                }
                if self.days.contains("금") {
                    self.daysBtn[4].isSelected = true
                }
                if self.days.contains("토") {
                    self.daysBtn[5].isSelected = true
                }
                if self.days.contains("일") {
                    self.daysBtn[6].isSelected = true
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
