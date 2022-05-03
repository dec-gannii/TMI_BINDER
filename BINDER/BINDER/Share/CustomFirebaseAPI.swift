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
public func GetEvaluationForStudentCell(self : StudentEvaluationCell) {
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
                                    self.setTextView("등록된 평가가 없습니다.")
                                    self.monthPickerView.text = "\(self.selectedMonth)"
                                    for document in querySnapshot!.documents {
                                        let evaluation = document.data()["evaluation"] as? String ??  "등록된 평가가 없습니다."
                                        self.setTextView(evaluation)
                                        self.monthPickerView.text = "\(self.selectedMonth)"
                                        LoadingHUD.isLoaded = true
                                    }
                                    self.monthPickerView.resignFirstResponder()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
