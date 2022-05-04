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
