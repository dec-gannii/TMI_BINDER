//
//  ScheduleVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit
import FSCalendar

struct ScheduleVCDBFunctions {
    func ShowScheduleList(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int) {
        var varScheduleTitles = scheduleTitles
        var varScheduleMemos = scheduleMemos
        varCount = count
        
        publicTitles.removeAll()
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
                    let scheduleData = document.data()
                    let scheduleTitle = scheduleData["title"] as? String ?? ""
                    let scheduleMemo = scheduleData["memo"] as? String ?? ""
                    
                    if (!scheduleTitles.contains(scheduleTitle)) {
                        // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                        varScheduleTitles.append(scheduleTitle)
                        publicTitles.append(scheduleTitle)
                        varScheduleMemos.append(scheduleMemo)
                    }
                    // 일정의 제목은 필수 항목이므로 일정 제목 개수만큼을 개수로 지정
                    varCount = varScheduleTitles.count
                }
            }
        }
    }
    
    func SetScheduleTexts(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int, scheduleCell : ScheduleCellTableViewCell, indexPathRow : Int) {
        // 데이터베이스에서 일정 리스트 가져오기
        var varScheduleTitles = scheduleTitles
        var varScheduleMemos = scheduleMemos
        varCount = count
        
        publicTitles.removeAll()
        let docRef = db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList")
        // Date field가 현재 날짜와 동일한 도큐먼트 모두 가져오기
        docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") }
            else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    let scheduleData = document.data()
                    let scheduleTitle = scheduleData["title"] as? String ?? ""
                    let scheduleMemo = scheduleData["memo"] as? String ?? ""
                    
                    if (!varScheduleTitles.contains(scheduleTitle)) {
                        // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                        varScheduleTitles.append(scheduleTitle)
                        publicTitles.append(scheduleTitle)
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
    
    func DeleteSchedule(type : String, date : String , indexPathRow : Int, scheduleListTableView : UITableView) {
        db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(publicTitles[indexPathRow]).delete() { err in
            if let err = err { print("Error removing document: \(err)") }
            else {
                print("Document successfully removed!")
                varCount = varCount - 1
                scheduleListTableView.reloadData()
            }
        }
        
        db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").getDocuments()
        {
            (querySnapshot, err) in
            
            if let err = err
            { print("Error getting documents: \(err)") }
            else {
                var count = 0
                for document in querySnapshot!.documents {
                    count += 1
                    print("\(document.documentID) => \(document.data())");
                }
                
                if (count == 1) {
                    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document("Count").setData(["count": 0])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                } else {
                    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document("Count").setData(["count": count-1])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                }
            }
        }
    }
    
    func GetBeforeEditSchedule(type : String, date : String, editingTitle : String, scheduleMemo : UITextView, schedulePlace : UITextField, scheduleTitle : UITextField, scheduleTime : UITextField) {
        // 내용이 있다는 의미이므로 데이터베이스에서 다시 받아와서 textfield의 값으로 설정
        db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(editingTitle).getDocument { (document, error) in
            if let document = document, document.exists {
                varIsEditMode = true
                let data = document.data()
                let memo = data?["memo"] as? String ?? ""
                scheduleMemo.text = memo
                if scheduleMemo.text != "" {
                    scheduleMemo.textColor = .black
                }
                let place = data?["place"] as? String ?? ""
                schedulePlace.text = place
                let title = data?["title"] as? String ?? ""
                scheduleTitle.text = title
                let time = data?["time"] as? String ?? ""
                scheduleTime.text = time
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func SaveEditSchedule(type : String, date : String, editingTitle : String, isEditMode : Bool, scheduleMemoTV : UITextView, schedulePlaceTF : UITextField, scheduleTitleTF : UITextField, scheduleTimeTF : UITextField, datestr : String, current_time_string : String) {
        // 원래 데이터베이스에 저장되어 있던 일정은 삭제하고 새롭게 수정한 내용으로 추가 후 현재 modal dismiss
        db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(editingTitle).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        
        if scheduleMemoTV.text == "(50자 이내로 작성해주세요.)" {
            scheduleMemoTV.text = ""
        }
        if schedulePlaceTF.text == "장소를 입력해주세요." {
            schedulePlaceTF.text = ""
        }
        if scheduleTimeTF.text == "시간을 입력해주세요." {
            schedulePlaceTF.text = ""
        }
        
        db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(scheduleTitleTF.text!).setData([
            "title": scheduleTitleTF.text!,
            "place": schedulePlaceTF.text!,
            "date" : datestr,
            "time": scheduleTimeTF.text!,
            "memo": scheduleMemoTV.text!,
            "savedTime": current_time_string ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func SaveSchedule(type : String, date : String, scheduleTitleTF : UITextField, scheduleMemoTV : UITextView, schedulePlaceTF : UITextField, scheduleTimeTF : UITextField, datestr : String, current_time_string : String) {
        if scheduleMemoTV.text == "(50자 이내로 작성해주세요.)" {
            scheduleMemoTV.text = ""
        }
        if schedulePlaceTF.text == "장소를 입력해주세요." {
            schedulePlaceTF.text = ""
        }
        if scheduleTimeTF.text == "시간을 입력해주세요." {
            schedulePlaceTF.text = ""
        }
        
        // 데이터베이스에 입력된 내용 추가
        db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(scheduleTitleTF.text!).setData([
            "title": scheduleTitleTF.text!,
            "place": schedulePlaceTF.text!,
            "date" : datestr,
            "time": scheduleTimeTF.text!,
            "memo": scheduleMemoTV.text!,
            "savedTime": current_time_string ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        // 존재하는 도큐먼트의 수만큼 Count에 숫자 더해주기
        db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").getDocuments()
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
                
                // 현재 존재하는 데이터가 하나면,
                if (count == 1) {
                    // 1으로 저장
                    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document("Count").setData(["count": count])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                } else {
                    // 현재 존재하는 데이터들이 여러 개면, Count 도큐먼트를 포함한 것이므로
                    // 하나를 뺀 수로 지정해서 저장해줌
                    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document("Count").setData(["count": count-1])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                }
            }
        }
    }
}
