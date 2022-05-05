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
import FSCalendar
import FirebaseStorage

public var linkBtnEmail : String = ""
public var linkBtnIndex : Int = 0
public var linkBtnSubject : String = ""
public var linkBtnName : String = ""
public var userType : String = ""
public var userEmail : String = ""
public var userPW : String = ""

public var sharedEvents : [Date] = []
public var sharedDays : [Date] = []
public var publicTitles: [String] = []

public var varCount = 0
public var varIsEditMode = false
public var sharedCurrentPW : String = ""
var count = 0

public func GetLinkButtonInfos(sender : UIButton, firstLabel : UILabel, secondLabel : UILabel, thirdLabel : UILabel, detailVC : DetailClassViewController, self : HomeViewController) {
    let db = Firestore.firestore()
    if (userType == "teacher") {
        // 설정해둔 버튼의 태그에 따라서 레이블의 이름을 가지고 비교 후 학생 관리 페이지로 넘어가기
        if ((sender as AnyObject).tag == 0) {
            linkBtnName = firstLabel.text!
        } else if ((sender as AnyObject).tag == 1) {
            linkBtnName = secondLabel.text!
        } else if ((sender as AnyObject).tag == 2) {
            linkBtnName = thirdLabel.text!
        }
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("name", isEqualTo: linkBtnName).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    linkBtnIndex = document.data()["index"] as? Int ?? 0
                    linkBtnEmail = document.data()["email"] as? String ?? ""
                    linkBtnSubject = document.data()["subject"] as? String ?? ""
                }
                
                detailVC.userName = linkBtnName
                detailVC.userSubject = linkBtnSubject
                detailVC.userEmail = linkBtnEmail
                detailVC.userIndex = linkBtnIndex
                detailVC.userType = userType
                
                detailVC.modalPresentationStyle = .fullScreen
                detailVC.modalTransitionStyle = .crossDissolve
                
                self.present(detailVC, animated: true, completion: nil)
            }
        }
    } else {
        // 설정해둔 버튼의 태그에 따라서 레이블의 이름을 가지고 비교 후 학생 관리 페이지로 넘어가기
        if ((sender as AnyObject).tag == 0) {
            linkBtnName = firstLabel.text!
        } else if ((sender as AnyObject).tag == 1) {
            linkBtnName = secondLabel.text!
        } else if ((sender as AnyObject).tag == 2) {
            linkBtnName = thirdLabel.text!
        }
        
        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("name", isEqualTo: linkBtnName).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    linkBtnIndex = document.data()["index"] as? Int ?? 0
                    linkBtnEmail = document.data()["email"] as? String ?? ""
                    linkBtnSubject = document.data()["subject"] as? String ?? ""
                }
                
                detailVC.userName = linkBtnName
                detailVC.userSubject = linkBtnSubject
                detailVC.userEmail = linkBtnEmail
                detailVC.userIndex = linkBtnIndex
                detailVC.userType = userType
                
                detailVC.modalPresentationStyle = .fullScreen
                detailVC.modalTransitionStyle = .crossDissolve
                
                self.present(detailVC, animated: true, completion: nil)
            }
        }
    }
}

public func ShowScheduleList(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int) {
    let db = Firestore.firestore()
    
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
                let scheduleTitle = document.data()["title"] as? String ?? ""
                let scheduleMemo = document.data()["memo"] as? String ?? ""
                
                if (!scheduleTitles.contains(scheduleTitle)) {
                    // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                    varScheduleTitles.append(scheduleTitle)
                    varScheduleMemos.append(scheduleMemo)
                }
                
                // 일정의 제목은 필수 항목이므로 일정 제목 개수만큼을 개수로 지정
                varCount = varScheduleTitles.count
            }
        }
    }
}

public func SetScheduleTexts(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int, scheduleCell : ScheduleCellTableViewCell, indexPathRow : Int) {
    // 데이터베이스에서 일정 리스트 가져오기
    let db = Firestore.firestore()
    
    var varScheduleTitles = scheduleTitles
    var varScheduleMemos = scheduleMemos
    varCount = count
    
    publicTitles.removeAll()
    
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

// 선생님 일정 불러오기
public func GetTeacherEvents(events : [Date], days : [Date], calendarView : FSCalendar) {
    let db = Firestore.firestore()
    // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let type = data?["type"] as? String ?? ""
            
            let formatter = DateFormatter()
            
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(abbreviation: "KST")
            
            sharedEvents.removeAll()
            sharedDays = days
            
            for index in 1...days.count-1 {
                let tempDay = "\(sharedDays[index])"
                let dateWithoutDays = tempDay.components(separatedBy: " ")
                formatter.dateFormat = "YYYY-MM-dd"
                let date = formatter.date(from: dateWithoutDays[0])!
                let datestr = formatter.string(from: date)
                
                let docRef = db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(datestr).collection("scheduleList")
                
                docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            // 사용할 것들 가져와서 지역 변수로 저장
                            let date = document.data()["date"] as? String ?? ""
                            
                            formatter.dateFormat = "YYYY-MM-dd"
                            let date_d = formatter.date(from: date)!
                            sharedEvents.append(date_d)
                            calendarView.reloadData()
                        }
                    }
                }
            }
        } else {
            print("Document does not exist")
        }
    }
}

// 학생 일정 불러오기
public func GetStudentEvents(events : [Date], days : [Date], calendarView : FSCalendar) {
    let db = Firestore.firestore()
    
    // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
    db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let type = data?["type"] as? String ?? ""
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(abbreviation: "KST")
            
            sharedEvents.removeAll()
            sharedDays = days
            
            for index in 1...days.count-1 {
                let tempDay = "\(sharedDays[index])"
                let dateWithoutDays = tempDay.components(separatedBy: " ")
                formatter.dateFormat = "YYYY-MM-dd"
                let date = formatter.date(from: dateWithoutDays[0])!
                let datestr = formatter.string(from: date)
                
                let docRef = db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(datestr).collection("scheduleList")
                
                docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            // 사용할 것들 가져와서 지역 변수로 저장
                            let date = document.data()["date"] as? String ?? ""
                            
                            formatter.dateFormat = "YYYY-MM-dd"
                            let date_d = formatter.date(from: date)!
                            sharedEvents.append(date_d)
                            calendarView.reloadData()
                        }
                    }
                }
            }
        } else {
            print("Document does not exist")
        }
    }
}

// 선생님 정보 가져오기
public func GetTeacherInfo(days : [Date], homeStudentScrollView : UIScrollView, stateLabel : UILabel) {
    let db = Firestore.firestore()
    // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let name = data?["name"] as? String ?? ""
            stateLabel.text = name + " 선생님 환영합니다!"
            if (Auth.auth().currentUser?.email == (data?["email"] as! String)) {
                userType = "teacher"
            } else {
                userType = data?["type"] as? String ?? ""
            }
            userEmail = data?["email"] as? String ?? ""
            userPW = data?["password"] as? String ?? ""
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(abbreviation: "KST")
            
            sharedEvents.removeAll()
            for index in 1...days.count-1 {
                let tempDay = "\(days[index])"
                let dateWithoutDays = tempDay.components(separatedBy: " ")
                formatter.dateFormat = "YYYY-MM-dd"
                let date = formatter.date(from: dateWithoutDays[0])!
                let datestr = formatter.string(from: date)
                
                db.collection(userType).document(Auth.auth().currentUser!.uid).collection("schedule").document(datestr).collection("scheduleList").whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            // 사용할 것들 가져와서 지역 변수로 저장
                            let date = document.data()["date"] as? String ?? ""
                            
                            formatter.dateFormat = "YYYY-MM-dd"
                            let date_d = formatter.date(from: date)!
                            
                            sharedEvents.append(date_d)
                        }
                    }
                }
            }
            homeStudentScrollView.isHidden = false
        } else {
            print("Document does not exist")
        }
    }
}

// 학생 정보 가져오기
public func GetStudentInfo(days : [Date], homeStudentScrollView : UIScrollView, stateLabel : UILabel) {
    let db = Firestore.firestore()
    
    db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let name = data?["name"] as? String ?? ""
            stateLabel.text = name + " 학생 환영합니다!"
            userEmail = data?["email"] as? String ?? ""
            userPW = data?["password"] as? String ?? ""
            if (Auth.auth().currentUser?.email == (data?["email"] as! String)) {
                userType = "student"
            } else {
                userType = data?["type"] as? String ?? ""
            }
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(abbreviation: "KST")
            
            sharedEvents.removeAll()
            
            for index in 1...days.count-1 {
                
                let tempDay = "\(days[index])"
                let dateWithoutDays = tempDay.components(separatedBy: " ")
                formatter.dateFormat = "YYYY-MM-dd"
                let date = formatter.date(from: dateWithoutDays[0])!
                let datestr = formatter.string(from: date)
                
                db.collection(userType).document(Auth.auth().currentUser!.uid).collection("schedule").document(datestr).collection("scheduleList").whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            // 사용할 것들 가져와서 지역 변수로 저장
                            let date = document.data()["date"] as? String ?? ""
                            formatter.dateFormat = "YYYY-MM-dd"
                            let date_d = formatter.date(from: date)!
                            
                            sharedEvents.append(date_d)
                        }
                    }
                }
            }
            homeStudentScrollView.isHidden = false
        } else {
            print("Document does not exist")
        }
    }
}

// 일정 리스트 보여주기
public func ShowScheduleList(date : String, scheduleListVC : ScheduleListViewController, self : HomeViewController) {
    let db = Firestore.firestore()
    db.collection(userType).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document("Count").addSnapshotListener { documentSnapshot, error in
        guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
        }
        guard let data = document.data() else {
            print("Document data was empty.")
            return
        }
        scheduleListVC.count = data["count"] as! Int
    }
    
    // 날짜 데이터 넘겨주기
    scheduleListVC.date = date
    scheduleListVC.type = userType
    scheduleListVC.modalPresentationStyle = .fullScreen
    self.present(scheduleListVC, animated: true, completion: nil)
}

public func DeleteSchedule(type : String, date : String , indexPathRow : Int, scheduleListTableView : UITableView) {
    let db = Firestore.firestore()
    
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(publicTitles[indexPathRow]).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
            varCount = varCount - 1
            scheduleListTableView.reloadData()
        }
    }
    
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

public func GetBeforeEditSchedule(type : String, date : String, editingTitle : String, scheduleMemo : UITextView, schedulePlace : UITextField, scheduleTitle : UITextField, scheduleTime : UITextField) {
    let db = Firestore.firestore()
    
    // 내용이 있다는 의미이므로 데이터베이스에서 다시 받아와서 textfield의 값으로 설정
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(editingTitle).getDocument { (document, error) in
        if let document = document, document.exists {
            varIsEditMode = true
            let data = document.data()
            let memo = data?["memo"] as? String ?? ""
            scheduleMemo.text = memo
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

public func SaveEditSchedule(type : String, date : String, editingTitle : String, isEditMode : Bool, scheduleMemoTV : UITextView, schedulePlaceTF : UITextField, scheduleTitleTF : UITextField, scheduleTimeTF : UITextField, datestr : String, current_time_string : String) {
    // 원래 데이터베이스에 저장되어 있던 일정은 삭제하고 새롭게 수정한 내용으로 추가 후 현재 modal dismiss
    let db = Firestore.firestore()
    
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(editingTitle).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
        }
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

public func SaveSchedule(type : String, date : String, scheduleTitleTF : UITextField, scheduleMemoTV : UITextView, schedulePlaceTF : UITextField, scheduleTimeTF : UITextField, datestr : String, current_time_string : String) {
    let db = Firestore.firestore()
    
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

public func GetTeacherMyClass(self : HomeViewController) {
    count = 0
    let db = Firestore.firestore()
    let labels = [self.HomeStudentIconLabel, self.HomeStudentIconSecondLabel, self.HomeStudentIconThirdLabel]
    let buttons = [self.firstLinkBtn, self.secondLinkBtn, self.thirdLinkBtn]
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                if ((querySnapshot?.documents.count)! >= 3) {
                    if count <= 2 {
                        let name = document.data()["name"] as? String ?? ""
                        labels[count]!.text = name
                        buttons[count]!.isHidden = false
                        labels[count]!.isHidden = false
                        count = count + 1
                    }
                } else {
                    if count < (querySnapshot?.documents.count)! {
                        let name = document.data()["name"] as? String ?? ""
                        labels[count]!.text = name
                        buttons[count]!.isHidden = false
                        labels[count]!.isHidden = false
                        count = count + 1
                    }
                }
                continue
            }
        }
    }
}

public func GetStudentMyClass(self : HomeViewController) {
    count = 0
    
    let db = Firestore.firestore()
    let labels = [self.HomeStudentIconLabel, self.HomeStudentIconSecondLabel, self.HomeStudentIconThirdLabel]
    let buttons = [self.firstLinkBtn, self.secondLinkBtn, self.thirdLinkBtn]
    
    db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                if ((querySnapshot?.documents.count)! >= 3) {
                    if count <= 2 {
                        let name = document.data()["name"] as? String ?? ""
                        labels[count]!.text = name
                        buttons[count]!.isHidden = false
                        labels[count]!.isHidden = false
                        count = count + 1
                    }
                } else {
                    if count < (querySnapshot?.documents.count)! {
                        let name = document.data()["name"] as? String ?? ""
                        labels[count]!.text = name
                        buttons[count]!.isHidden = false
                        labels[count]!.isHidden = false
                        count = count + 1
                    }
                }
                continue
            }
        }
    }
}

public func Secession(self : SecessionViewController) {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser // 사용자 정보 가져오기
    
    user?.delete { error in
        if let error = error {
            // An error happened.
            print("delete user error : \(error)")
        } else {
            // Account deleted.
            // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
            db.collection("teacher").document(user!.uid).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            db.collection("student").document(user!.uid).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            db.collection("parent").document(user!.uid).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
        print("delete success, go sign in page")
        
        // 로그인 화면(첫화면)으로 다시 이동
        guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
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
            print("Error getting documents: \(err)")
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
            print("Error getting documents: \(err)")
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

public func ShowPortfolio(self : ShowPortfolioViewController) {
    let db = Firestore.firestore()
    // 입력된 이메일과 동일한 값을 가지는 이메일 필드가 있다면 수행
    db.collection("teacher").whereField("email", isEqualTo: self.teacherEmailTextField.text!).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            // 도큐먼트 존재 안 하면 유효하지 않은 선생님 이메일이라고 alert 발생
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                let alert = UIAlertController(title: "탐색 오류", message: StringUtils.tEmailNotExist.rawValue, preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
                alert.addAction(okAction)
                self.present(alert, animated: false, completion: nil)
                return
            }
            
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                self.view.endEditing(true)
                let email = document.data()["email"] as? String ?? ""
                // 포트폴리오를 보여주는 화면 present
                guard let portfolioVC = self.storyboard?.instantiateViewController(withIdentifier: "PortfolioTableViewController") as? PortfolioTableViewController else { return }
                portfolioVC.isShowMode = true
                portfolioVC.showModeEmail = email
                self.present(portfolioVC, animated: true, completion: nil)
            }
        }
    }
    /// 변수 다시 공백으로 바꾸기
    self.teacherEmailTextField.text = ""
}

public func GetUserInfoInPortfolioTableViewController(self : PortfolioTableViewController) {
    let db = Firestore.firestore()
    
    self.teacherAttitudeArray.removeAll()
    self.teacherManagingSatisfyScoreArray.removeAll()
    
    if (self.isShowMode == true) { /// 포트폴리오 조회인 경우
        self.editBtn.isHidden = true // 수정 버튼 숨기기
        self.db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.teacherName.text = document.data()["name"] as? String ?? ""
                    self.teacherEmail.text = document.data()["email"] as? String ?? ""
                    let profile = document.data()["profile"] as? String ?? ""
                    let uid = document.data()["uid"] as? String ?? ""
                    self.teacherUid = uid
                    
                    self.db.collection("teacherEvaluation").document(uid).collection("evaluation").whereField("teacherUid", isEqualTo: uid).getDocuments() {
                        (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let teacherAttitude = document.data()["teacherAttitude"] as? String ?? ""
                                self.teacherAttitudeArray.append(Int(teacherAttitude)!)
                                let teacherManagingSatisfyScore = document.data()["teacherManagingSatisfyScore"] as? String ?? ""
                                self.teacherManagingSatisfyScoreArray.append(Int(teacherManagingSatisfyScore)!)
                            }
                        }
                    }
                    
                    self.infos.removeAll() // 원래 있는 제목 정보들 모두 지우기
                    
                    self.db.collection("teacher").document(uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            
                            let eduText = data?["eduHistory"] as? String ?? "" // 학력 정보
                            let classText = data?["classMethod"] as? String ?? "" // 수업 방식
                            let extraText = data?["extraExprience"] as? String ?? "" // 과외 경력
                            let time = data?["time"] as? String ?? "" // 과외 시간
                            let contact = data?["contact"] as? String ?? "" // 연락 수단
                            let manage = data?["manage"] as? String ?? "" // 학생 관리 방법
                            
                            if (eduText != "") {
                                self.infos.append("학력사항")
                            }
                            if (classText != "") {
                                self.infos.append("수업 방식")
                            }
                            if (extraText != "") {
                                self.infos.append("과외 경력")
                            }
                            if (time != "") {
                                self.infos.append("과외 시간")
                            }
                            if (contact != "") {
                                self.infos.append("연락 수단")
                            }
                            if (manage != "") {
                                self.infos.append("학생 관리 방법")
                            }
                            self.infos.append("선생님 평가")
                        }
                    }
                    self.teacherImage.kf.setImage(with: URL(string: profile)!)
                    self.teacherImage.makeCircle()
                }
            }
        }
    } else {
        self.infos.removeAll()
        self.teacherAttitudeArray.removeAll()
        self.teacherManagingSatisfyScoreArray.removeAll()
        
        self.db.collection("teacherEvaluation").document(Auth.auth().currentUser!.uid).collection("evaluation").whereField("teacherUid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let teacherAttitude = document.data()["teacherAttitude"] as? String ?? ""
                    self.teacherAttitudeArray.append(Int(teacherAttitude)!)
                    let teacherManagingSatisfyScore = document.data()["teacherManagingSatisfyScore"] as? String ?? ""
                    self.teacherManagingSatisfyScoreArray.append(Int(teacherManagingSatisfyScore)!)
                }
            }
        }
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let eduText = data?["eduHistory"] as? String ?? ""
                let classText = data?["classMethod"] as? String ?? ""
                let extraText = data?["extraExprience"] as? String ?? ""
                let time = data?["time"] as? String ?? ""
                let contact = data?["contact"] as? String ?? ""
                let manage = data?["manage"] as? String ?? ""
                
                if (eduText != "") {
                    self.infos.append("학력사항")
                }
                if (classText != "") {
                    self.infos.append("수업 방식")
                }
                if (extraText != "") {
                    self.infos.append("과외 경력")
                }
                if (time != "") {
                    self.infos.append("과외 시간")
                }
                if (contact != "") {
                    self.infos.append("연락 수단")
                }
                if (manage != "") {
                    self.infos.append("학생 관리 방법")
                }
                self.infos.append("선생님 평가")
            }
        }
        
        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let name = data?["name"] as? String ?? ""
                self.teacherName.text = name
                let email = data?["email"] as? String ?? ""
                self.teacherEmail.text = email
                let profile = document.data()!["profile"] as? String ?? ""
                self.teacherImage.kf.setImage(with: URL(string: profile)!)
                self.teacherImage.makeCircle()
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
}

public func GetPortfolioFactors(self : PortfolioTableViewController, indexPath : IndexPath, cell : PortfolioDefaultCell) {
    let db = Firestore.firestore()
    
    if Auth.auth().currentUser?.uid != nil { // 현재 사용자의 uid가 nil이 아니면
        self.teacherUid = Auth.auth().currentUser!.uid // self.teacherUid 를 설정
    }
    
    var teacherAttitudeScoreAvg = 0
    var teacherAttitudeScoreSum = 0
    for score in self.teacherAttitudeArray {
        teacherAttitudeScoreSum += score
        teacherAttitudeScoreAvg = teacherAttitudeScoreSum / self.teacherAttitudeArray.count
    }
    
    var teacherManagingSatisfyScoreAvg = 0
    var teacherManagingSatisfyScoreSum = 0
    for score in self.teacherManagingSatisfyScoreArray {
        teacherManagingSatisfyScoreSum += score
        teacherManagingSatisfyScoreAvg = teacherManagingSatisfyScoreSum / self.teacherManagingSatisfyScoreArray.count
    }
    
    if (self.showModeEmail == "") {
        self.showModeEmail = (Auth.auth().currentUser?.email)!
    }
    
    db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                let uid = document.data()["uid"] as? String ?? ""
                
                self.db.collection("teacher").document(uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        
                        let eduText = data?["eduHistory"] as? String ?? "저장된 내용이 없습니다."
                        let classText = data?["classMethod"] as? String ?? "저장된 내용이 없습니다."
                        let extraText = data?["extraExprience"] as? String ?? "저장된 내용이 없습니다."
                        let time = data?["time"] as? String ?? "저장된 내용이 없습니다."
                        let contact = data?["contact"] as? String ?? "저장된 내용이 없습니다."
                        let manage = data?["manage"] as? String ?? "저장된 내용이 없습니다."
                        let portfolioShow = data?["portfolioShow"] as? String ?? "저장된 내용이 없습니다."
                        
                        if self.infos[indexPath.row] == "연락 수단" {
                            cell.content.text = contact
                        } else if self.infos[indexPath.row] == "학력사항" {
                            cell.content.text = eduText
                        } else if self.infos[indexPath.row] == "수업 방식" {
                            cell.content.text = classText
                        } else if self.infos[indexPath.row] == "과외 경력" {
                            cell.content.text = extraText
                        } else if self.infos[indexPath.row] == "선생님 평가" {
                            cell.content.text = "\(String(describing: self.teacherName.text!)) 선생님의 수업 태도는 평균적으로 \(teacherAttitudeScoreAvg)점이고, 학부모님들의 학생 관리 만족도는 평균적으로 \(teacherManagingSatisfyScoreAvg)점입니다." // 연결 필요
                        } else if self.infos[indexPath.row] == "과외 시간" {
                            cell.content.text = time
                        } else if self.infos[indexPath.row] == "학생 관리 방법" {
                            cell.content.text = manage
                        }
                        
                        if (portfolioShow == "Off" && self.isShowMode == true) {
                            let message = "비공개 설정 되어있습니다."
                            if self.infos[indexPath.row] == "연락 수단" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "학력사항" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "수업 방식" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "과외 경력" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "선생님 평가" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "과외 시간" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "학생 관리 방법" {
                                cell.content.text = message
                            }
                        }
                        cell.title.text = self.infos[indexPath.row]
                        
                        print("Document data: \(dataDescription)")
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
}

public func AddPortfolioFactors(title : String, content : String) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
        "\(title)": content
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func GetPortfolioPlots(self : PortfolioEditViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let eduHistory = data?["eduHistory"] as? String ?? ""
            self.eduHistoryTV.text = eduHistory
            // placeholder 설정
            if (self.eduHistoryTV.text == "") {
                self.placeholderSetting(self.eduHistoryTV)
                self.textViewDidBeginEditing(self.eduHistoryTV)
                self.textViewDidEndEditing(self.eduHistoryTV)
            }
            let classMethod = data?["classMethod"] as? String ?? ""
            self.classMetTV.text = classMethod
            // placeholder 설정
            if (self.classMetTV.text == "") {
                self.placeholderSetting(self.classMetTV)
                self.textViewDidBeginEditing(self.classMetTV)
                self.textViewDidEndEditing(self.classMetTV)
            }
            let extraExprience = data?["extraExprience"] as? String ?? ""
            self.extraExpTV.text = extraExprience
            // placeholder 설정
            if (self.extraExpTV.text == "") {
                self.placeholderSetting(self.extraExpTV)
                self.textViewDidBeginEditing(self.extraExpTV)
                self.textViewDidEndEditing(self.extraExpTV)
            }
            let manage = data?["manage"] as? String ?? ""
            self.manageTV.text = manage
            // placeholder 설정
            if (self.manageTV.text == "") {
                self.placeholderSetting(self.manageTV)
                self.textViewDidBeginEditing(self.manageTV)
                self.textViewDidEndEditing(self.manageTV)
            }
            let contact = data?["contact"] as? String ?? ""
            self.contactTV.text = contact
            // placeholder 설정
            if (self.contactTV.text == "") {
                self.placeholderSetting(self.contactTV)
                self.textViewDidBeginEditing(self.contactTV)
                self.textViewDidEndEditing(self.contactTV)
            }
            let time = data?["time"] as? String ?? ""
            self.timeTV.text = time
            // placeholder 설정
            if (self.timeTV.text == "") {
                self.placeholderSetting(self.timeTV)
                self.textViewDidBeginEditing(self.timeTV)
                self.textViewDidEndEditing(self.timeTV)
            }
            self.evaluationTV.text = "선생님이 수정할 수 없습니다."
            self.evaluationTV.isEditable = false
            
            let showPortfolio = data?["portfolioShow"] as? String ?? ""
            if (showPortfolio == "Off") {
                self.showPortfolio = "Off"
            } else {
                self.showPortfolio = "On"
            }
        } else {
            print("Document does not exist")
        }
    }
}

public func SaveEditedPlot(self : PortfolioEditViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            
            let email = data?["email"] as? String ?? ""
            
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                "portfolioEmail": email
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            print("Document data: \(dataDescription)")
        } else {
            print("Document does not exist")
        }
    }
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").setData([
        "eduHistory": self.eduHistoryTV.text ?? "",
        "classMethod": self.classMetTV.text ?? "",
        "extraExprience": self.extraExpTV.text ?? "",
        "portfolioShow": self.showPortfolio,
        "time": self.timeTV.text ?? "",
        "manage": self.manageTV.text ?? "",
        "contact": self.contactTV.text ?? ""
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func GetUserInfoForMyPage(self : MyPageViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            LoginRepository.shared.doLogin {
                self.nameLabel.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
                self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
                self.type = "teacher"
                let url = URL(string: LoginRepository.shared.teacherItem!.profile)!
                self.imageView.kf.setImage(with: url)
                self.imageView.makeCircle()
            } failure: { error in
                self.showDefaultAlert(msg: "")
            }
        } else {
            db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let userName = data?["name"] as? String ?? ""
                    self.nameLabel.text = "\(userName) 학생"
                    let userEmail = data?["email"] as? String ?? ""
                    self.teacherEmail.text = userEmail
                    let profile =  data?["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                    let goal = data?["goal"] as? String ?? "목표를 작성하지 않았습니다."
                    self.type = "student"
                    let url = URL(string: profile)!
                    self.imageView.kf.setImage(with: url)
                    self.imageView.makeCircle()
                    self.viewDecorating()
                    self.openPortfolioSwitch.removeFromSuperview()
                    self.portfoiolBtn.removeFromSuperview()
                    self.pageViewTitleLabel.text = "목표"
                    self.pageViewContentLabel.text = goal
                    self.pageViewContentLabel.numberOfLines = 2
                    
                    self.pageViewContentLabel.rightAnchor.constraint(equalTo: self.pageView.rightAnchor
                                                                     , constant: -20).isActive = true
                    self.pageViewTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
                    self.pageViewTitleLabel.topAnchor.constraint(equalTo: self.pageView.topAnchor
                                                                 , constant: 20).isActive = true
                    self.pageView.heightAnchor.constraint(equalToConstant: 120)
                        .isActive = true
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

public func GetPortfolioShow(self : MyPageViewController) {
    let db = Firestore.firestore()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            
            let isShowOK = data?["portfolioShow"] as? String ?? ""
            if (isShowOK == "On") {
                self.openPortfolioSwitch.setOn(true, animated: true)
            } else {
                self.openPortfolioSwitch.setOn(false, animated: true)
            }
            print ("Document data does not exist")
        }
    }
}

public func PortfolioToggleButtonClicked(self : MyPageViewController) {
    let db = Firestore.firestore()
    
    if (self.openPortfolioSwitch.isOn) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
            "portfolioShow": "On"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    } else {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
            "portfolioShow": "Off"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
}

public func SaveImage(self : MyPageViewController) {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var storageRef = storage.reference()
    
    let image = self.imageView.image!
    if let data = image.pngData(){
        let urlRef = storageRef.child("image/\(self.profile!).png")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        let uploadTask = urlRef.putData(data, metadata: metadata){ (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            
            urlRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                
                self.db.collection(self.type).document(Auth.auth().currentUser!.uid).updateData([
                    "profile":"\(downloadURL)",
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                if (self.type == "teacher") {
                    LoginRepository.shared.teacherItem?.profile = "\(downloadURL)"
                } else if (self.type == "student") {
                    LoginRepository.shared.studentItem?.profile = "\(downloadURL)"
                }
            }
        }
    }
}
