//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

public var sharedCurrentPW : String = ""
public var userType : String = ""

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

public func GetPW() {
    let db = Firestore.firestore()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
            sharedCurrentPW = data?["password"] as? String ?? ""
            print ("\(sharedCurrentPW) : sharedCurrentPW")
        } else {
            // 먼저 설정한 선생님 정보의 uid의 경로가 없다면 학생 정보에서 재탐색
            db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                    sharedCurrentPW = data?["password"] as? String ?? ""
                    print ("\(sharedCurrentPW) : sharedCurrentPW1")
                } else {
                    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                            sharedCurrentPW = data?["password"] as? String ?? ""
                            print ("\(sharedCurrentPW) : sharedCurrentPW2")
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
}

public func SaveTeacherInfos(name : String, password : String , parentPW : String) {
    let db = Firestore.firestore()
    // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
    db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
        "name": name,
        "password": password,
        "parentPW": parentPW
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func SaveStudentInfos(name : String, password : String , parentPassword : UITextField) {
    let db = Firestore.firestore()
    // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
    db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
        "name": name,
        "password": password,
        "goal": parentPassword.text!
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func SaveParentInfos (name : String, password : String, childPhoneNumber : String) {
    let db = Firestore.firestore()
    // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
    db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
        "name": name,
        "password": password,
        "childPhoneNumber": childPhoneNumber
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func GetUserInfoForEditInfo(nameTF : UITextField, emailLabel : UILabel, parentPassword : UITextField, parentPasswordLabel : UILabel) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            // 이름, 이메일, 학부모 인증용 비밀번호, 사용자의 타입
            let userName = data?["name"] as? String ?? ""
            nameTF.text = userName
            let userEmail = data?["email"] as? String ?? ""
            emailLabel.text = userEmail
            let parentPW = data?["parentPW"] as? String ?? ""
            parentPassword.text = parentPW
            userType = data?["type"] as? String ?? ""
            sharedCurrentPW = data?["password"] as? String ?? ""
        } else {
            // 현재 사용자에 해당하는 선생님 문서가 없으면 학생 문서로 다시 검색
            db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let userName = data?["name"] as? String ?? ""
                    nameTF.text = userName
                    let userEmail = data?["email"] as? String ?? ""
                    emailLabel.text = userEmail
                    userType = data?["type"] as? String ?? ""
                    sharedCurrentPW = data?["password"] as? String ?? ""
                    let goal = data?["goal"] as? String ?? ""
                    parentPasswordLabel.text = "목표"
                    parentPassword.text = goal
                } else {
                    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let userName = data?["name"] as? String ?? ""
                            nameTF.text = userName
                            let userEmail = data?["email"] as? String ?? ""
                            emailLabel.text = userEmail
                            userType = data?["type"] as? String ?? ""
                            sharedCurrentPW = data?["password"] as? String ?? ""
                            parentPasswordLabel.text = "자녀 휴대전화 번호"
                            let childPhoneNumber = data?["childPhoneNumber"] as? String ?? ""
                            parentPassword.text = childPhoneNumber
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
}
