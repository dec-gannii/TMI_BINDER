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

public func UpdateClassInfo(self : EditClassVC, schedule : String) {
    let db = Firestore.firestore()
    
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

public func GetClassInfo(self : EditClassVC) {
    let db = Firestore.firestore()
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
