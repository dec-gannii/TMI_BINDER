//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore

public func ShowScheduleList(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int) {
    let db = Firestore.firestore()
    
    var varScheduleTitles = scheduleTitles
    var varScheduleMemos = scheduleMemos
    var varCount: Int = count
    
    // 데이터베이스에서 일정 리스트 가져오기
    let docRef = db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList")
    // Date field가 현재 날짜와 동일한 도큐먼트 모두 가져오기
    docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                // 사용할 것들 가져와서 지역 변수로 저장
                let scheduleTitle = document.data()["title"] as? String ?? ""
                let scheduleMemo = document.data()["memo"] as? String ?? ""
                
                if (!scheduleTitles.contains(scheduleTitle)) {
                    // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                    varScheduleTitles.append(scheduleTitle)
                    varScheduleMemos.append(scheduleMemo)
                }
                
                // 일정의 제목은 필수 항목이므로 일정 제목 개수만큼을 개수로 지정
                varCount = scheduleTitles.count
            }
        }
    }
}

public func SetScheduleTexts(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int, scheduleCell : ScheduleCellTableViewCell, indexPathRow : Int) {
    // 데이터베이스에서 일정 리스트 가져오기
    let db = Firestore.firestore()
    
    var varScheduleTitles = scheduleTitles
    var varScheduleMemos = scheduleMemos
    var varCount: Int = count
    
    let docRef = db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList")
    // Date field가 현재 날짜와 동일한 도큐먼트 모두 가져오기
    docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                // 사용할 것들 가져와서 지역 변수로 저장
                let scheduleTitle = document.data()["title"] as? String ?? ""
                let scheduleMemo = document.data()["memo"] as? String ?? ""
                
                if (!varScheduleTitles.contains(scheduleTitle)) {
                    // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                    varScheduleTitles.append(scheduleTitle)
                    varScheduleMemos.append(scheduleMemo)
                }
                
                // 일정의 제목은 필수 항목이므로 일정 제목 개수만큼을 개수로 지정
                varCount = varScheduleTitles.count
            }
            for i in 0...indexPathRow {
                // 가져온 내용들을 순서대로 일정 셀의 텍스트로 설정
                scheduleCell.scheduleTitle.text = varScheduleTitles[i]
                scheduleCell.scheduleMemo.text = varScheduleMemos[i]
            }
        }
    }
}

public func GetUserInfoForClassList(self : MyClassVC) {
    let db = Firestore.firestore()
    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
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
                    let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                    
                    let url = URL(string: profile)!
                    self.teacherImage.kf.setImage(with: url)
                    self.setTeacherInfo()
                    
                    LoadingHUD.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        LoadingHUD.hide()
                    }
                }
            }
        }
    }
    
    db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
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
                    
                    let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                    let url = URL(string: profile)!
                    self.teacherImage.kf.setImage(with: url)
                    
                    self.setStudentInfo()
                    
                    LoadingHUD.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        LoadingHUD.hide()
                    }
                }
            }
        }
    }
}

public func SetMyClasses(self : MyClassVC) {
    let db = Firestore.firestore()
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
                            let recentDate = classDt["recentDate"] as? String ?? ""
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
                let recentDate = classDt["recentDate"] as? String ?? ""
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

public func MoveToDetailClassVC (self : MyClassVC, sender : UIButton) {
    var index: Int!
    var name: String!
    var email: String!
    var subject: String!
    var type: String!
    
    let db = Firestore.firestore()
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
                
                guard let weekendVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController") as? DetailClassViewController else { return }
                
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


public func SearchStudent(self : AddStudentVC, email : String) {
    let db = Firestore.firestore()
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
                let item = StudentItem(age: age, email: email, goal: goal, name: name, password: password, phone: phone, profile: profile)
                
                /// 값 넘어가기
                self.performSegue(withIdentifier: "inputClassSegue", sender: item)
            }
            /// 변수 다시 공백으로 바꾸기
            self.emailTf.text = ""
        }
}

public func GetStudentClassCount(self : ClassInfoVC, uid : String) {
    let db = Firestore.firestore()
    self.studentCount = 0
    db.collection("student").document(uid).collection("class").getDocuments()
    {
        (querySnapshot, err) in
        
        if let err = err
        {
            print("Error getting documents: \(err)");
        }
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

public func GetTeacherClassCount(self : ClassInfoVC) {
    let db = Firestore.firestore()
    self.studentCount = 0
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments()
    {
        (querySnapshot, err) in
        
        if let err = err
        {
            print("Error getting documents: \(err)");
        }
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

public func SaveClassInfo(self : ClassInfoVC, subject : String, payDate : String, payment : String , schedule : String) {
    // 데이터베이스 연결
    var studentUid = ""
    let db = Firestore.firestore()
    
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
                                studentUid = document.data()["uid"] as? String ?? ""
                                
                                db.collection("student").document(studentUid).collection("class").document("\(LoginRepository.shared.teacherItem!.name)(\(LoginRepository.shared.teacherItem!.email)) " + self.subjectTextField.text!).setData([
                                    "email" : "\(LoginRepository.shared.teacherItem!.email)",
                                    "name" : "\(LoginRepository.shared.teacherItem!.name)",
                                    "subject" : self.subjectTextField.text!,
                                    "currentCnt" : 0,
                                    "totalCnt" : 8,
                                    "circleColor" : self.classColor1,
                                    "recentDate" : "",
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
