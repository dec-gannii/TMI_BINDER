//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import FirebaseStorage
import CryptoKit
import UIKit
import AVKit
import Kingfisher
import FSCalendar

public var linkBtnEmail : String = ""
public var linkBtnIndex : Int = 0
public var linkBtnSubject : String = ""
public var linkBtnName : String = ""

public var userType : String = ""
public var userEmail : String = ""
public var userName : String = ""
public var userSubject : String = ""
public var userPW : String = ""

public var sharedCurrentPW : String = ""

public var sharedEvents : [Date] = []
public var sharedDays : [Date] = []
public var publicTitles: [String] = []

public var varCount = 0
public var varIsEditMode = false
var count = 0

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

/// 로그인을 위한 DB 메소드들
public func LogInAndShowHomeVC (email : String, password: String, self : LogInViewController) {
    let db = Firestore.firestore()
    // 별 오류 없으면 로그인 되어서 홈 뷰 컨트롤러 띄우기
    db.collection("parent").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                // 사용할 것들 가져와서 지역 변수로 저장
                guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                self.present(tb, animated: true, completion: nil)
                return
            }
            
            guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                //아니면 종료
                return
            }
            
            // 아이디와 비밀번호 정보 넘겨주기
            homeVC.pw = password
            homeVC.id = email
            if (Auth.auth().currentUser?.isEmailVerified == true){
                homeVC.verified = true
            } else { homeVC.verified = false }
            
            guard let myClassVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                //아니면 종료
                return
            }
            
            guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                return
            }
            guard let myPageVC =
                    self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                return
            }
            
            // tab bar 설정
            let tb = UITabBarController()
            tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
            self.present(tb, animated: true, completion: nil)
        }
    }
}

public func GoogleLogIn(googleCredential : AuthCredential, self : LogInViewController) {
    Auth.auth().signIn(with: googleCredential) {
        (authResult, error) in if let error = error {
            print("Firebase sign in error: \(error)")
            return
        } else {
            guard let TypeSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController") as? TypeSelectViewController else {
                //아니면 종료
                return
            }
            
            //화면전환
            if ((Auth.auth().currentUser) != nil) {
                // 홈 화면으로 바로 이동
                guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                    //아니면 종료
                    return
                }
                
                if (Auth.auth().currentUser?.isEmailVerified == true){
                    homeVC.verified = true
                } else { homeVC.verified = false }
                
                //화면전환
                guard let myClassVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                    //아니면 종료
                    return
                }
                
                guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                    return
                }
                guard let myPageVC =
                        self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                    return
                }
                
                // tab bar 설정
                let tb = UITabBarController()
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
                self.present(tb, animated: true, completion: nil)
                
                self.isLogouted = false
            } else {
                TypeSelectVC.isGoogleSignIn = true
                TypeSelectVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                TypeSelectVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(TypeSelectVC, animated: true)
            }
        }
    }
}

public func AppleLogIn(credential : OAuthCredential, self : LogInViewController) {
    let db = Firestore.firestore()
    // Sign in with Firebase.
    Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
        if (error != nil) {
            print("ERROR : \(error)")
            return
        } else {
            Firestore.firestore().collection("teacher").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let email = document.data()["email"] as? String ?? ""
                        let password = document.data()["password"] as? String ?? ""
                        
                        guard let homeVC = self?.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                            //아니면 종료
                            return
                        }
                        
                        // 아이디와 비밀번호 정보 넘겨주기
                        homeVC.pw = password
                        homeVC.id = email
                        
                        if (Auth.auth().currentUser?.isEmailVerified == true){
                            homeVC.verified = true
                        } else { homeVC.verified = false }
                        
                        guard let myClassVC = self?.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                            //아니면 종료
                            return
                        }
                        
                        guard let questionVC = self?.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                            return
                        }
                        guard let myPageVC =
                                self?.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                            return
                        }
                        
                        // tab bar 설정
                        let tb = UITabBarController()
                        tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
                        self!.present(tb, animated: true, completion: nil)
                        
                    }
                    Firestore.firestore().collection("student").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                
                                let email = document.data()["email"] as? String ?? ""
                                let password = document.data()["password"] as? String ?? ""
                                
                                guard let homeVC = self?.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                                    //아니면 종료
                                    return
                                }
                                
                                // 아이디와 비밀번호 정보 넘겨주기
                                homeVC.pw = password
                                homeVC.id = email
                                
                                if (Auth.auth().currentUser?.isEmailVerified == true){
                                    homeVC.verified = true
                                } else { homeVC.verified = false }
                                
                                guard let myClassVC = self?.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                                    //아니면 종료
                                    return
                                }
                                
                                guard let questionVC = self?.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                                    return
                                }
                                guard let myPageVC =
                                        self?.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                                    return
                                }
                                
                                // tab bar 설정
                                let tb = UITabBarController()
                                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
                                self!.present(tb, animated: true, completion: nil)
                            }
                            Firestore.firestore().collection("parent").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        
                                        guard let tb = self?.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                                        tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                        self!.present(tb, animated: true, completion: nil)
                                        
                                        return
                                    }
                                    // type select 화면으로 이동
                                    guard let typeSelectVC = self?.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController") as? TypeSelectViewController else { return }
                                    typeSelectVC.modalPresentationStyle = .fullScreen
                                    typeSelectVC.modalTransitionStyle = .crossDissolve
                                    typeSelectVC.name = Auth.auth().currentUser?.displayName ?? ""
                                    typeSelectVC.email = Auth.auth().currentUser?.email ?? ""
                                    typeSelectVC.isAppleLogIn = true
                                    
                                    self!.present(typeSelectVC, animated: true, completion: nil)
                                    return
                                }
                            }
                        }
                        return
                    }
                }
                return
            }
        }
    }
}

public func DeleteUser(self : StudentSubInfoController) {
    let user = Auth.auth().currentUser // 사용자 정보 가져오기
    let db = Firestore.firestore()
    
    user?.delete { error in
        if let error = error {
            // An error happened.
            print("delete user error : \(error)")
        } else {
            // Account deleted.
            // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
            var docRef = db.collection("teacher").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("student").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("parent").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
}

public func UpdateStudentSubInfo(age : String, phonenum : String, goal : String) {
    let db = Firestore.firestore()
    db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
        "age": age,
        "phonenum": phonenum,
        "goal": goal
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func UpdateTeacherSubInfo(parentPW : String) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
        "parentPW": parentPW
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func CheckStudentPhoneNumberForParent(phoneNumber: String, self: StudentSubInfoController, goal : String) {
    let db = Firestore.firestore()
    db.collection("teacher").whereField("email", isEqualTo: goal).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                return
            }
            for document in querySnapshot!.documents {
                // 선생님 비밀번호
                self.tpassword = document.data()["parentPW"] as? String ?? ""
                
                if self.phonenum == "" {
                    self.phoneAlertLabel.text = "전화번호를 작성해주세요."
                    self.phoneAlertLabel.isHidden = false
                }
                else if ((self.phonenumTextField.text!.contains("-") && self.phonenumTextField.text!.count >= 15) || (self.phonenumTextField.text!.count >= 12 && !self.phonenumTextField.text!.contains("-"))) {
                    self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                    self.phoneAlertLabel.isHidden = false
                }
                else if self.tpassword != self.ageShowPicker.text! {
                    self.ageAlertLabel.text = StringUtils.tEmailNotMatch.rawValue
                    self.ageAlertLabel.isHidden = false
                }
                else {
                    self.goalAlertLabel.isHidden = true
                    self.phoneAlertLabel.isHidden = true
                    self.ageAlertLabel.isHidden = true
                    
                    if phoneNumber != ""{
                        db.collection("student").whereField("phonenum", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                                self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                                self.phoneAlertLabel.isHidden = false
                            } else {
                                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                    return
                                }
                                for document in querySnapshot!.documents {
                                    var sphonenum = document.data()["phonenum"] as? String ?? ""
                                    
                                    if sphonenum == phoneNumber {
                                        db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                                            "teacherEmail": self.goal,
                                            "childPhoneNumber": phoneNumber
                                        ]) { err in
                                            if let err = err {
                                                print("Error adding document: \(err)")
                                            }
                                        }
                                        guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                                        tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                        self.present(tb, animated: true, completion: nil)
                                    } else {
                                        self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                                        self.phoneAlertLabel.isHidden = false
                                    }
                                }
                            }
                        }
                    }
                    else {
                        self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                        self.phoneAlertLabel.isHidden = false
                    }
                }
            }
        }
    }
}

public func SaveInfoForSignUp (self : SignInViewController, number: Int, name: String, email: String, password: String, type: String) {
    let db = Firestore.firestore()
    db.collection("\(type)").document(Auth.auth().currentUser!.uid).setData([
        "name": name,
        "email": email,
        "password": password,
        "type": type,
        "uid": Auth.auth().currentUser?.uid,
        "profile": Auth.auth().currentUser?.photoURL?.absoluteString ?? "https://ifh.cc/g/Lt9Ip8.png"
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
    
    guard let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfoController") as? StudentSubInfoController else {
        //아니면 종료
        return
    }
    subInfoVC.type = type
    subInfoVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
    subInfoVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
    self.present(subInfoVC, animated: true, completion: nil)
}

public func DeleteUserWhileSignUp () {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser // 사용자 정보 가져오기
    
    user?.delete { error in
        if let error = error {
            // An error happened.
            print("delete user error : \(error)")
        } else {
            // Account deleted.
            // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
            var docRef = db.collection("teacher").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("student").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("parent").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
}

public func CreateUser(type : String, self : SignInViewController, name : String, id : String, pw : String) {
    let db = Firestore.firestore()
    db.collection(type).whereField("email", isEqualTo: id).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                self.emailAlertLabel.text = StringUtils.emailExistAlert.rawValue
                self.emailAlertLabel.isHidden = false
                self.emailTextField.text = ""
                return
            }
            
            if self.emailAlertLabel.isHidden == true {
                // 이름, 이메일, 비밀번호, 나이가 모두 유효하다면, && self.isValidAge(age)
                if (self.isValidName(name) && self.isValidEmail(id) && self.isValidPassword(pw) ) {
                    // 사용자를 생성
                    Auth.auth().createUser(withEmail: id, password: pw) {(authResult, error) in
                        if (type != "parent"){
                            Auth.auth().currentUser?.sendEmailVerification(completion: {(error) in
                                print("sended to " + id)
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                }
                            })
                        }
                        
                        // 정보 저장
                        SaveInfoForSignUp(self: self, number: SignInViewController.number, name: name, email: id, password: pw, type: self.type)
                        SignInViewController.number = SignInViewController.number + 1
                        guard let user = authResult?.user else {
                            return
                        }
                    }
                } else {
                    if (self.isGoogleSignIn == false) {
                        // 유효하지 않다면, 에러가 난 부분 label로 알려주기 위해 error label 숨김 해제
                        if (!self.isValidEmail(id)){
                            self.emailAlertLabel.isHidden = false
                            self.emailAlertLabel.text = StringUtils.emailValidationAlert.rawValue
                        }
                        if (!self.isValidPassword(pw)) {
                            self.pwAlertLabel.isHidden = false
                            self.pwAlertLabel.text = StringUtils.passwordValidationAlert.rawValue
                        }
                    } else {
                        // 정보 저장
                        SaveInfoForSignUp(self: self, number: SignInViewController.number, name: name, email: id, password: pw, type: type)
                        SignInViewController.number = SignInViewController.number + 1
                        
                        // 추가 정보를 입력하는 뷰로 이동
                        guard let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfoController") as? StudentSubInfoController else {
                            //아니면 종료
                            return
                        }
                        subInfoVC.type = type
                        subInfoVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        subInfoVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                        self.present(subInfoVC, animated: true, completion: nil)
                    }
                    if (!self.isValidName(name)) {
                        self.nameAlertLabel.isHidden = false
                        self.nameAlertLabel.text = StringUtils.nameValidationAlert.rawValue
                    }
                }
            }
        }
    }
}

/// 나의 수업을 위한 DB 메소드들
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

/// 설정을 위한 DB 메소드들
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
        } else {
            // 먼저 설정한 선생님 정보의 uid의 경로가 없다면 학생 정보에서 재탐색
            db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                    sharedCurrentPW = data?["password"] as? String ?? ""
                } else {
                    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                            sharedCurrentPW = data?["password"] as? String ?? ""
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

/// 포트폴리오를 위한 DB 메소드들
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
            print("Document data: \(dataDescription)")
        } else {
            print("Document does not exist")
        }
    }
}

/// 학부모 페이지를 위한 DB 메소드
public func GetParentUserInfo(self : ParentHomeViewController) {
    let db = Firestore.firestore()
    db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            if let err = err {
                print("Error getting documents(inMyClassView): \(err)")
            } else {
                /// 문서 존재하면
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 이름 받아서 학부모 이름 label의 text를 'OOO 학부모님'으로 지정
                    
                    let name = document.data()["name"] as? String ?? ""
                    self.parentNameLabel.text = name + " 학부모님"
                }
            }
        }
    }
}

public func SetEvaluation(self : ParentHomeViewController) {
    let db = Firestore.firestore()
    // parent collection에서 현재 로그인한 uid와 같은 uid 정보를 가지는 문서 찾기
    db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            /// nil이 아닌지 확인한다.
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                return
            }
            /// nil이 아니면
            /// 문서 존재하면
            for document in snapshot.documents {
                print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                // 등록된 자녀 휴대폰 번호를 가져와서
                let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                
                // student collection에서 가져온 휴대폰 번호와 같은 본인 휴대폰 번호 정보를 가지는 문서 찾기
                db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let studentUid = document.data()["uid"] as? String ?? "" // 학생 uid 정보
                            self.studentUid = studentUid // self.studentUid 변수에도 저장해주기
                            
                            // 클래스 정보를 가져오기 위해서 고정으로 설정된 8번의 횟수를 이용해 class 모두 찾기
                            db.collection("student").document(studentUid).collection("class").whereField("totalCnt", isEqualTo: 8).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    /// 조회하기 위해 원래 있던 것 들 다 지움
                                    self.evaluationItem.removeAll()
                                    
                                    for document in querySnapshot!.documents {
                                        let evaluationData = document.data()
                                        
                                        let name = evaluationData["name"] as? String ?? "" // 선생님 이름
                                        let email = evaluationData["email"] as? String ?? "" // 선생님 이메일
                                        let subject = evaluationData["subject"] as? String ?? "" // 과목
                                        let currentCnt = evaluationData["currentCnt"] as? Int ?? 0 // 현재 횟수
                                        let totalCnt = evaluationData["totalCnt"] as? Int ?? 8 // 총 횟수
                                        let evaluation = evaluationData["evaluation"] as? String ?? "선택된 달이 없습니다." // 평가 내용
                                        let circleColor = evaluationData["circleColor"] as? String ?? "026700" // 원 색상
                                        let index = evaluationData["index"] as? Int ?? 0
                                        
                                        self.teacherName = name
                                        self.teacherNames.append(name)
                                        self.teacherEmail = email
                                        self.teacherEmails.append(email)
                                        self.subject = subject
                                        
                                        let item = EvaluationItem(email: email, name: name, evaluation: evaluation, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: circleColor, subject: subject, index: index)
                                        
                                        self.evaluationItem.append(item) // evaluationItem 배열에 append 해주기
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

public func DeleteChildPhone() {
    let db = Firestore.firestore()
    /// parent/현재 유저의 uid에서 문서를 가져와서 문서가 있다면
    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            /// parent의 childPhoneNumber 를 없애주기 (공백으로 갱신)
            db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                "childPhoneNumber": ""
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
}

public func GetParentInfo(self : ParentMyPageViewController) {
    let db = Firestore.firestore()
    // parent collection에서 uid 필드가 현재 사용자의 uid와 동일한 문서 찾기
    db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            if let err = err {
                print("Error getting documents(inMyClassView): \(err)")
            } else {
                /// 문서 존재하면
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    if LoadingHUD.isLoaded == false {
                        LoadingHUD.show()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            LoadingHUD.isLoaded = true
                            LoadingHUD.hide()
                        }
                    }
                    
                    let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png" // 학부모 프로필 이미지 링크 가져오기
                    let name = document.data()["name"] as? String ?? "" // 학부모 이름
                    let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? "" // 자녀 휴대폰 번호
                    
                    if (childPhoneNumber == "") { /// 자녀 휴대폰 번호 공백이면
                        // 자녀 휴대폰 번호 backgroundview 안 보여도 됨
                        self.childInfoBackgroundView.isHidden = true
                    } else { /// 공백 아니면
                        // 자녀 휴대폰 번호 backgroundview 보이도록 설정
                        self.childInfoBackgroundView.isHidden = false
                    }
                    
                    var childPhoneNumberWithDash = "" // '-'가 들어간 번호로 다시 만들어 주기 위해 사용
                    if (childPhoneNumber.contains("-")) { /// '-'가 있는 휴대폰 번호의 경우
                        childPhoneNumberWithDash = childPhoneNumber // '-'가 들어간 번호 변수에 그대로 사용
                    } else {  /// '-'가 없는 휴대폰 번호의 경우
                        var firstPart = "" // 010 파트
                        var secondPart = "" // 중간 번호 파트
                        var thirdPart = "" // 끝 번호 파트
                        var count = 0 // 몇 개의 숫자를 셌는지 파악하기 위한 변수
                        
                        for char in childPhoneNumber{ // childPhoneNumber가 String이므로 하나하나의 문자를 사용
                            if (count >= 0 && count <= 2) { // 0-2번째에 해당하는 수는 010 파트로 저장
                                firstPart += String(char)
                            } else if (count >= 3 && count <= 6){ // 3-6번째에 해당하는 수는 중간 번호 파트로 저장
                                secondPart += String(char)
                            } else if (count >= 7 && count <= 10){ // 7-10번째에 해당하는 수는 끝 번호 파트로 저장
                                thirdPart += String(char)
                            }
                            // 한 번 할 때마다 count 하나씩 증가
                            count = count + 1
                            
                        }
                        // '-'가 들어간 번호 변수에 010 파트와 중간 번호 하트, 끝 번호 파트를 '-'로 연결해서 저장
                        childPhoneNumberWithDash = firstPart + " - " + secondPart + " - " + thirdPart
                    }
                    
                    // student collection에서 학생의 휴대전화번호가 '-'가 들어간 번호 변수의 값과 같다면
                    db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumberWithDash).getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            if let err = err {
                                print("Error getting documents(inMyClassView): \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let childName = document.data()["name"] as? String ?? "" // 학생 (자녀) 이름
                                    self.childNameLabel.text = childName + " 학생" // 자녀 이름 label의 이름으로 사용
                                }
                            }
                        }
                    }
                    self.childPhoneNumberLabel.text = childPhoneNumberWithDash // 학생 (자녀) 휴대전화 번호 text로 지정
                    self.nameLabel.text = name // 학부모 이름 label은 가져온 학부모의 이름으로 지정
                    let url = URL(string: profile)! // url은 가져온 학부모의 profile 링크를 URL로 변환해 저장
                    self.profileImageView.kf.setImage(with: url) // profileImageView의 image를 가져온 url을 사용해 설정
                    self.profileImageView.makeCircle() // 프로필 이미지를 원으로 보이도록 설정
                }
            }
        }
    }
}

public func SaveProfileImage(self : ParentMyPageViewController, profile : String) {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var storageRef = storage.reference()
    
    let image = self.profileImageView.image!
    if let data = image.pngData(){
        let urlRef = storageRef.child("image/\(profile).png")
        
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
                
                db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                    "profile":"\(downloadURL)",
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            }
        }
    }
}


public func GetChildrenInfo(self : ParentDetailEvaluationViewController) {
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
                let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
                
                /// student collection에서 위에서 가져온 childPhoneNumber와 동일한 휴대전화 번호 정보를 가지는 사람이 있는지 찾기
                db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            
                            LoadingHUD.show()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                LoadingHUD.hide()
                            }
                            
                            let studentName = document.data()["name"] as? String ?? "" // 학생 이름
                            self.studentName = studentName // self.studentName에 저장
                            self.monthlyEvaluationTitle.text = "이번 달 " + studentName + " 학생은..." // 이번 달 평가 제목에 사용
                            let studentEmail = document.data()["email"] as? String ?? "" // 학생 이메일
                            self.studentEmail = studentEmail
                        }
                    }
                }
            }
        }
    }
}

public func GetStudentMonthlyEvaluations(self : ParentDetailEvaluationViewController) {
    let db = Firestore.firestore()
    /// parent collection / 현재 사용자 uid의 경로에서 정보를 가져오기
    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let childPhoneNumber = data!["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
            
            /// student collection에서 위에서 가져온 childPhoneNumber와 동일한 휴대전화 번호 정보를 가지는 사람이 있는지 찾기
            db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    // 현재로 설정된 달의 월말 평가가 등록되지 않은 경우
                    self.monthlyEvaluationTextView.text = "\(self.month)달 월말 평가가 등록되지 않았습니다."
                    
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let studentUid = document.data()["uid"] as? String ?? "" // 학생 uid
                        
                        /// student collection / studentUid / class collection에서 index필드의 값이 self.index와 동일한 문서를 찾기
                        db.collection("student").document(studentUid).collection("class").whereField("index", isEqualTo: self.index).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let name = document.data()["name"] as? String ?? "" // 선생님 이름
                                    self.teacherName = name // 선생님 이름으로 설정
                                    let email = document.data()["email"] as? String ?? "" // 선생님 이메일
                                    self.teacherEmail = email // 선생님 이메일로 설정
                                    let subject = document.data()["subject"] as? String ?? "" // 과목
                                    self.subject = subject // 과목으로 설정
                                    
                                    self.navigationBarTitle.title = self.studentName + " 학생 " + self.subject + " 월말평가" // navigationBar의 title text에 학생 이름과 과목을 포함하여 지정
                                    
                                    /// student collection / studentUid / class / 선생님이름(선생님이메일) 과목 / Evaluation 경로에서 month가 현재 설정된 달의 값과 같은 문서 찾기
                                    db.collection("student").document(studentUid).collection("class").document(name + "(" + email + ") " + self.subject).collection("Evaluation").whereField("month", isEqualTo: self.month).getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            print(">>>>> document 에러 : \(err)")
                                        } else {
                                            for document in querySnapshot!.documents {
                                                let evaluationData = document.data()
                                                let evaluation = evaluationData["evaluation"] as? String ?? "아직 이번 달 월말 평가가 등록되지 않았습니다." // 평가 내용 정보
                                                self.monthlyEvaluationTextView.text = evaluation // 평가 내용 text로 설정
                                                self.monthlyEvaluationTextView.isEditable = false // 수정 불가능하도록 설정
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
}

public func GetStudentDailyEvaluations (self : ParentDetailEvaluationViewController) {
    // 데이터베이스 경로
    let db = Firestore.firestore()
    let formatter = DateFormatter()
    self.events.removeAll()
    
    db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                
                db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                            
                            db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let studentEmail = document.data()["email"] as? String ?? "" // 학생 이메일
                                        
                                        db.collection("teacher").document(teacherUid).collection("class").whereField("email", isEqualTo: self.studentEmail).getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print(">>>>> document 에러 : \(err)")
                                            } else {
                                                for document in querySnapshot!.documents {
                                                    print("\(document.documentID) => \(document.data())")
                                                    let subject = document.data()["subject"] as? String ?? ""
                                                    
                                                    for index in 1...self.days.count-1 {
                                                        let tempDay = "\(self.days[index])"
                                                        let dateWithoutDays = tempDay.components(separatedBy: " ")
                                                        formatter.dateFormat = "YYYY-MM-dd"
                                                        let date = formatter.date(from: dateWithoutDays[0])!
                                                        let datestr = formatter.string(from: date)
                                                        
                                                        db.collection("teacher").document(teacherUid).collection("class").document(self.studentName + "(" + studentEmail + ") " + subject).collection("Evaluation").whereField("evaluationDate", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                                                            if let err = err {
                                                                print("Error getting documents: \(err)")
                                                            } else {
                                                                for document in querySnapshot!.documents {
                                                                    print("\(document.documentID) => \(document.data())")
                                                                    // 사용할 것들 가져와서 지역 변수로 저장
                                                                    let date = document.data()["evaluationDate"] as? String ?? ""
                                                                    
                                                                    formatter.dateFormat = "YYYY-MM-dd"
                                                                    let date_d = formatter.date(from: date)!
                                                                    self.events.append(date_d)
                                                                    self.calendarView.reloadData()
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
                    }
                }
            }
        }
    }
}

public func GetUserAndClassInfo(self : TeacherEvaluationViewController) {
    let db = Firestore.firestore()
    /// parent collection / 현재 사용자 uid 경로에서 문서 찾기
    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists { /// 문서 있으면
            let data = document.data()
            let childPhoneNumber = data!["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
            ///  student collection에 가져온 학생 전화번호와 동일한 전화번호 정보를 가지는 문서 찾기
            db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    /// 문서 있으면
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let studentName = document.data()["name"] as? String ?? "" // 학생 이름
                        self.studentName = studentName
                        
                        db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                                    
                                    /// parent collection / 현재 사용자 uid / teacherEvaluation collection / 선생님이름(선생님이메일) 과목 / evaluation 경로에서 문서 찾기
                                    db.collection("teacherEvaluation").document(teacherUid).collection("evaluation").document(studentName + " " + self.month).getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            let data = document.data()
                                            let teacherAttitude = data!["teacherAttitude"] as? String ?? "" // 선생님 태도 점수
                                            let teacherManagingSatisfyScore = data!["teacherManagingSatisfyScore"] as? String ?? "" // 학생 관리 만족도 점수
                                            self.teacherAttitude.text = teacherAttitude // 선생님 태도 점수 text 지정
                                            self.teacherManagingSatisfyScore.text = teacherManagingSatisfyScore // 학생 관리 만족도 점수 지정
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.studentTitle.text = studentName + " 학생의 " + self.date + " 수업은..." // 학생 평가 title text 설정
                        self.evaluationTextView.isEditable = false // 평가 textview 수정 못하도록 설정
                    }
                }
            }
        } else {
            print("Document does not exist")
        }
    }
}

public func GetEvaluation (self : TeacherEvaluationViewController) {
    let db = Firestore.firestore()
    // 데이터베이스 경로
    db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                self.teacherUid = teacherUid
                let parentDocRef = self.db.collection("parent")
                parentDocRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                            
                            db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let studentEmail = document.data()["email"] as? String ?? "" // 학생 이메일
                                        let studentName = document.data()["name"] as? String ?? "" // 학생 이메일
                                        
                                        db.collection("teacher").document(teacherUid).collection("class").whereField("email", isEqualTo: studentEmail).getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print(">>>>> document 에러 : \(err)")
                                            } else {
                                                for document in querySnapshot!.documents {
                                                    print("\(document.documentID) => \(document.data())")
                                                    let subject = document.data()["subject"] as? String ?? ""
                                                    
                                                    db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + subject).collection("Evaluation").whereField("evaluationDate", isEqualTo: self.date).getDocuments() { (querySnapshot, err) in
                                                        if let err = err {
                                                            print("Error getting documents: \(err)")
                                                        } else {
                                                            for document in querySnapshot!.documents {
                                                                print("\(document.documentID) => \(document.data())")
                                                                // 사용할 것들 가져와서 지역 변수로 저장
                                                                let evaluationMemo = document.data()["evaluationMemo"] as? String ?? "선택된 날짜에는 수업이 없었습니다."
                                                                let homeworkCompletion = document.data()["homeworkCompletion"] as? Int ?? 0
                                                                self.averageHomeworkCompletion.text = "\(homeworkCompletion) 점"
                                                                let classAttitude = document.data()["classAttitude"] as? Int ?? 0
                                                                self.averageClassAttitude.text = "\(classAttitude) 점"
                                                                let testScore = document.data()["testScore"] as? Int ?? 0
                                                                self.averageTestScore.text = "\(testScore) 점"
                                                                self.evaluationTextView.text = evaluationMemo
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
                }
            }
        }
    }
}

public func SaveTeacherEvaluation(self : TeacherEvaluationViewController) {
    let db = Firestore.firestore()
    /// parent collection / 현재 사용자 Uid / teacherEvaluation / 선생님이름(선생님이메일) / 현재 달 collection / evaluation 아래에 선생님 태도 점수와 학생 관리 만족도 점수 저장
    db.collection("teacherEvaluation").document(self.teacherUid).collection("evaluation").document(self.studentName + " " + self.month)
        .setData([
            "teacherUid": self.teacherUid,
            "teacherAttitude": self.teacherAttitude.text!,
            "teacherManagingSatisfyScore": self.teacherManagingSatisfyScore.text!
        ])
    { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func SaveMonthlyEvaluation(self : DetailClassViewController) {
    let date = self.selectedMonth + "월"
    self.db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument {(document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let teacherName = data!["name"] as? String ?? ""
            let teacherEmail = data!["email"] as? String ?? ""
            
            if let email = self.userEmail {
                self.db.collection("student").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let uid = document.data()["uid"] as? String ?? ""
                            
                            self.db.collection("student").document(uid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).collection("Evaluation").document(date).setData([
                                "month": date,
                                "isMonthlyEvaluation": true,
                                "evaluation": self.monthlyEvaluationTextView.text!
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

public func DeleteClass (self : DetailClassViewController) {
    let db = Firestore.firestore()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).delete()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument {(document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let teacherName = data!["name"] as? String ?? ""
            let teacherEmail = data!["email"] as? String ?? ""
            if let email = self.userEmail {
                let studentPath = self.db.collection("student").whereField("email", isEqualTo: email)
                studentPath.getDocuments() {
                    (QuerySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in QuerySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let studentUid = document.data()["uid"] as? String ?? "" // 학생의 uid 변수에 저장
                            db.collection("student").document(studentUid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).delete()
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
}

public func SaveDailyEvaluation(self : DetailClassViewController) {
    let db = Firestore.firestore()
    // 경로는 각 학생의 class의 Evaluation
    if(self.userType == "teacher") {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)").setData([
            "progress": self.progressTextView.text!,
            "testScore": Int(self.testScoreTextField.text!) ?? 0,
            "homeworkCompletion": Int(self.homeworkScoreTextField.text!) ?? 0,
            "classAttitude": Int(self.classScoreTextField.text!) ?? 0,
            "evaluationMemo": self.evaluationMemoTextView.text!,
            "evaluationDate": self.dateStrWithoutDays ?? "",
            "todayClassTime": Int(self.classTimeTextField.text!) ?? 0
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
            // 저장 이후에는 다시 안 보이도록 함
            self.monthlyEvaluationBackgroundView.isHidden = true
            self.evaluationOKBtn.isHidden = true
            self.evaluationView.isHidden = true
            
            self.progressTextView.text = ""
            self.testScoreTextField.text = ""
            self.evaluationMemoTextView.text = ""
        }
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                var currentCnt = data?["currentCnt"] as? Int ?? 0
                let subject = data?["subject"] as? String ?? "" // 과목
                let payType = data?["payType"] as? String ?? ""
                var count = 0
                
                if (payType == "T") {
                    if (currentCnt+Int(self.classTimeTextField.text!)! >= 8) {
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                            "currentCnt": (currentCnt + Int(self.classTimeTextField.text!)!) % 8
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    } else {
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                            "currentCnt": currentCnt + Int(self.classTimeTextField.text!)!
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                    count = currentCnt + Int(self.classTimeTextField.text!)!
                } else if (payType == "C") {
                    if (currentCnt+1 >= 8) {
                        currentCnt = currentCnt % 8
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                            "currentCnt": currentCnt + 1
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    } else {
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                            "currentCnt": currentCnt + 1
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                    count = currentCnt + 1
                }
                
                db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let name =  data?["name"] as? String ?? "" // 선생님 이름
                        let email = data?["email"] as? String ?? "" // 선생님 이메일
                        
                        db.collection("student").whereField("email", isEqualTo: self.userEmail!).getDocuments() { (querySnapshot, err) in
                            if let err = err { // 학생 이메일이랑 같으면
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    // 사용할 것들 가져와서 지역 변수로 저장
                                    let uid = document.data()["uid"] as? String ?? "" // 학생 uid
                                    let path = name + "(" + email + ") " + subject
                                    self.db.collection("student").document(uid).collection("class").document(path).updateData([
                                        "currentCnt": count,
                                    ]) { err in
                                        if let err = err {
                                            print("Error adding document: \(err)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
        self.evaluationView.isHidden = true
        self.evaluationOKBtn.isHidden = true
    } else if (self.userType == "student") {
        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)").setData([
            "summary": self.progressTextView.text!,
            "prepare": Int(self.testScoreTextField.text!) ?? 0,
            "satisfy": Int(self.homeworkScoreTextField.text!) ?? 0,
            "level": Int(self.classScoreTextField.text!) ?? 0,
            "evaluationMemo": self.evaluationMemoTextView.text!,
            "evaluationDate": self.dateStrWithoutDays ?? ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
            // 저장 이후에는 다시 안 보이도록 함
            self.evaluationOKBtn.isHidden = true
            self.evaluationView.isHidden = true
            
            self.progressTextView.text = ""
            self.testScoreTextField.text = ""
            self.evaluationMemoTextView.text = ""
        }
    }
}

public func GetEvaluations(self : DetailClassViewController, dateStr : String) {
    let db = Firestore.firestore()
    // 데이터베이스 경로
    if (self.userType == "teacher") {
        // 데이터를 받아와서 각각의 값에 따라 textfield 값 설정 (만약 없다면 공백 설정, 있다면 그 값 불러옴)
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document(dateStr).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dateStrWithoutDays = data?["evaluationDate"] as? String ?? ""
                
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let homeworkCompletion = data?["homeworkCompletion"] as? Int ?? 0
                if (homeworkCompletion == 0) {
                    self.homeworkScoreTextField.text = ""
                } else {
                    self.homeworkScoreTextField.text = "\(homeworkCompletion)"
                }
                
                let classAttitude = data?["classAttitude"] as? Int ?? 0
                if (classAttitude == 0) {
                    self.classScoreTextField.text = ""
                } else {
                    self.classScoreTextField.text = "\(classAttitude)"
                }
                
                let progressText = data?["progress"] as? String ?? ""
                if (progressText != "") {
                    self.progressTextView.text = progressText
                }
                
                let evaluationMemo = data?["evaluationMemo"] as? String ?? ""
                if (evaluationMemo != "") {
                    self.evaluationMemoTextView.text = evaluationMemo
                }
                
                let todayClassTime = data?["todayClassTime"] as? Int ?? 0
                if (todayClassTime == 0) {
                    self.classTimeTextField.text = ""
                } else {
                    self.classTimeTextField.text = "\(todayClassTime)"
                }
                
                let testScore = data?["testScore"] as? Int ?? 0
                if (testScore == 0) {
                    self.testScoreTextField.text = ""
                } else {
                    self.testScoreTextField.text = "\(testScore)"
                }
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
                // 값 다시 공백 설정
                self.testScoreTextField.text = ""
                self.homeworkScoreTextField.text = ""
                self.classScoreTextField.text = ""
            }
        }
        
        db.collection("student").whereField("email", isEqualTo: self.userEmail!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    let studentUid = document.data()["uid"] as? String ?? ""
                    
                    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents { // 문서가 있다면
                                print("\(document.documentID) => \(document.data())")
                                let teacherName = document.data()["name"] as? String ?? ""
                                let teacherEmail = document.data()["email"] as? String ?? ""
                                
                                db.collection("student").document(studentUid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).collection("Evaluation").document(self.selectedMonth + "월").getDocument(){ (document, error) in
                                    if let document = document, document.exists {
                                        let data = document.data()
                                        let evaluation = data!["evaluation"] as? String ?? ""
                                        self.monthlyEvaluationTextView.text = evaluation
                                        self.monthlyEvaluationTextView.textColor = .black
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    } else if (self.userType == "student") {
        // 데이터를 받아와서 각각의 값에 따라 textfield 값 설정 (만약 없다면 공백 설정, 있다면 그 값 불러옴)
        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document("\(self.date!)").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let date = data?["evaluationDate"] as? String ?? ""
                
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let prepare = data?["prepare"] as? Int ?? 0
                if (prepare == 0) {
                    self.homeworkScoreTextField.text = ""
                } else {
                    self.homeworkScoreTextField.text = "\(prepare)"
                }
                
                let summary = data?["summary"] as? Int ?? 0
                if (summary == 0) {
                    self.progressTextView.text = ""
                } else {
                    self.progressTextView.text = "\(summary)"
                }
                
                let satisfy = data?["satisfy"] as? Int ?? 0
                if (summary == 0) {
                    self.classScoreTextField.text = ""
                } else {
                    self.classScoreTextField.text = "\(satisfy)"
                }
                
                let evaluationMemo = data?["evaluationMemo"] as? String ?? ""
                self.evaluationMemoTextView.text = evaluationMemo
                
                let level = data?["level"] as? Int ?? 0
                if (level == 0) {
                    self.testScoreTextField.text = ""
                } else {
                    self.testScoreTextField.text = "\(level)"
                }
                
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
                self.resetTextFields()
            }
        }
    } else {
        // 그대로 숨김 유지
        self.evaluationOKBtn.isHidden = true
        self.evaluationView.isHidden = true
    }
}

public func CheckmarkButtonClicked(self : DetailClassViewController, checkTime : Bool, sender : UIButton) {
    let db = Firestore.firestore()
    if(self.userType == "teacher"){
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").document(self.todoDoc[sender.tag]).updateData([
            "check": checkTime
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
            
        }
    } else {
        db.collection("teacher").document(self.teacherUid).collection("class").document(self.studentName + "(" + self.studentEmail + ") " + self.userSubject).collection("ToDoList").document(self.todoDoc[sender.tag]).updateData([
            "check": checkTime
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}

public func AddToDoListFactors(self : DetailClassViewController, checkTime : Bool) {
    let db = Firestore.firestore()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").addDocument(data: ["todo" : self.todoTF.text, "check" : checkTime])
    { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("data is inserted!")
            
        }
    }
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").getDocuments {(snapshot, error) in
        if let snapshot = snapshot {
            snapshot.documents.map { doc in
                if doc.data()["todo"] != nil {
                    self.todoDoc.append(doc.documentID)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

public func GetScores(self : DetailClassViewController, studentEmail : String) {
    let db = Firestore.firestore()
    // 학생의 정보들 중 이메일이 동일한 정보 불러오기
    var studentUid = ""
    db.collection("student").whereField("email", isEqualTo: studentEmail).getDocuments() {
        (QuerySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in QuerySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                studentUid = document.data()["uid"] as? String ?? "" // 학생의 uid 변수에 저장
            }
        }
        
        // 그래프 정보 저장 경로
        db.collection("student").document(studentUid).collection("Graph").document("Count").getDocument {(document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                let countOfScores = data?["count"] as? Int ?? 0
                self.db.collection("student").document(studentUid).collection("Graph").whereField("isScore", isEqualTo: "true")
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let type = document.data()["type"] as? String ?? ""
                                let score = Double(document.data()["score"] as? String ?? "0.0")
                                if (countOfScores > 0) {
                                    if (countOfScores == 1) {
                                        self.days.insert(type, at: 0)
                                        self.scores.insert(score!, at: 0)
                                    } else {
                                        for i in stride(from: 0, to: 1, by: 1) {
                                            print ("i : \(i)")
                                            self.days.insert(document.data()["type"] as? String ?? "", at: i)
                                            self.scores.insert(Double(document.data()["score"] as? String ?? "0.0")!, at: i)
                                        }
                                    }
                                    self.setChart(dataPoints: self.days, values: self.scores)
                                } else {
                                    self.barChartView.noDataText = "데이터가 없습니다."
                                    self.barChartView.noDataFont = .systemFont(ofSize: 20)
                                    self.barChartView.noDataTextColor = .lightGray
                                }
                            }
                        }
                    }
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
}

public func GetUserInfoInDetailClassVC (self : DetailClassViewController) {
    let db = Firestore.firestore()
    // 선생님이면
    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                ///nil인지 확인
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                
                for document in snapshot.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    // 선생님이므로 성적 추가하는 버튼은 보이지 않도록 superview에서 삭제
                    self.plusButton.isHidden = true
                    
                    if let index = self.userIndex { // userIndex가 nil이 아니라면
                        // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                            // 네비게이션 바의 이름도 설정해주기
                                            let name = document.data()["name"] as? String ?? ""
                                            let payType = document.data()["payType"] as? String ?? ""
                                            
                                            if (payType == "T") {
                                                self.classTimeTextField.isEnabled = true
                                            } else if (payType == "C") {
                                                self.classTimeTextField.isEnabled = false
                                            }
                                            
                                            let currentCnt = document.data()["currentCnt"] as? Int ?? 0
                                            self.currentCnt = currentCnt
                                            self.userName = name
                                            self.questionLabel.text = "오늘 " + self.userName + " 학생의 수업 참여는 어땠나요?"
                                            self.userEmail = document.data()["email"] as? String ?? ""
                                            self.userSubject = document.data()["subject"] as? String ?? ""
                                            self.monthlyEvaluationQuestionLabel.text = "이번 달 " + self.userName + " 학생은 전반적으로 어땠나요?"
                                            self.classNavigationBar.topItem!.title = self.userName + " 학생"
                                            
                                            self.todoDoc.removeAll()
                                            self.todos.removeAll()
                                            self.todoCheck.removeAll()
                                            
                                            // todolist도 가져오기
                                            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").getDocuments {(snapshot, error) in
                                                if let snapshot = snapshot {
                                                    
                                                    snapshot.documents.map { doc in
                                                        
                                                        if doc.data()["todo"] != nil{
                                                            // 순서대로 todolist를 담는 배열에 추가해주기
                                                            self.todoDoc.append(doc.documentID)
                                                            self.todos.append(doc.data()["todo"] as! String)
                                                            self.todoCheck.append(doc.data()["check"] as! Bool)
                                                            print("doc: \(self.todoDoc), list: \(self.todos), check : \(self.todoCheck)")
                                                        }
                                                    }
                                                } else {
                                                    print("Document does not exist")
                                                }
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
            }
        }
    
    // 학생이면
    // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
    db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                ///nil인지 확인
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                
                for document in snapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    self.studentName = document.data()["name"] as? String ?? ""
                    self.studentEmail = document.data()["email"] as? String ?? ""
                    let teacherDocRef = self.db.collection("teacher")
                    
                    if let email = self.userEmail { // 사용자의 이메일이 nil이 아니라면
                        // 선생님들 정보의 경로 중 이메일이 일치하는 선생님 찾기
                        self.db.collection("teacher").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    self.teacherUid = document.data()["uid"] as? String ?? ""
                                    
                                    self.todoDoc.removeAll()
                                    self.todos.removeAll()
                                    self.todoCheck.removeAll()
                                    
                                    // 선생님의 수업 목록 중 학생과 일치하는 정보 불러오기
                                    self.db.collection("teacher").document(self.teacherUid).collection("class").document(self.studentName + "(" + self.studentEmail + ") " + self.userSubject).collection("ToDoList").getDocuments {(snapshot, error) in
                                        if let snapshot = snapshot {
                                            
                                            snapshot.documents.map { doc in
                                                
                                                if doc.data()["todo"] != nil{
                                                    // 순서대로 todolist를 담는 배열에 추가해주기
                                                    
                                                    self.todoDoc.append(doc.documentID)
                                                    self.todos.append(doc.data()["todo"] as! String)
                                                    self.todoCheck.append(doc.data()["check"] as! Bool)
                                                }
                                            }
                                        } else {
                                            print("Document does not exist")
                                        }
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                    // 학생이면 투두리스트 추가를 하지 못하도록 설정
                    self.plusButton.isHidden = false
                    self.okButton.isHidden = true
                    self.todoTF.isHidden = true
                    // 학생이면 수업 수정 버튼 보이지 않도록 설정
                    self.editBtn.isHidden = true
                }
            }
        }
}

public func DeleteToDoList(self: DetailClassViewController, editingStyle: UITableViewCell.EditingStyle, tableView : UITableView, indexPath : IndexPath) {
    let db = Firestore.firestore()
    if self.userType == "teacher" {
        if editingStyle == .delete {
            
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("ToDoList").document(self.todoDoc[indexPath.row]).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            self.todos.remove(at: indexPath.row)
            self.todoDoc.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
        }
    }
}

public func SaveGraphScore(todayStudy: String, todayScore : String, self : PlusGraphViewController) {
    let db = Firestore.firestore()
    // 데이터 저장
    db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph").document(todayStudy).setData([
        "type": todayStudy,
        "score":todayScore,
        "isScore": "true"
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
    db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph").getDocuments()
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
                db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph").document("Count").setData(["count": count])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            } else {
                // 현재 존재하는 데이터들이 여러 개면, Count 도큐먼트를 포함한 것이므로
                // 하나를 뺀 수로 지정해서 저장해줌
                db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph").document("Count").setData(["count": count-1])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            }
            if let preVC = self.presentingViewController {
                preVC.dismiss(animated: true, completion: nil)
            }
        }
    }
}

public func GetScoreForEdit(self : PlusGraphViewController, todayStudy: String) {
    let db = Firestore.firestore()
    db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph").whereField("type", isEqualTo: todayStudy)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let score = document.data()["score"] as? String ?? ""
                        self.scoreTextField.text = score
                        break
                    }
                }
            }
        }
    self.scoreTextField.text = ""
}

/// 질문방을 위한 DB 메소드
public func UpdateImage(self : QuestionPlusViewController) {
    let db = Firestore.firestore()
    db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    
                    if let index = self.index { // userIndex가 nil이 아니라면
                        // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                        self.type = "student"
                        self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                            // 네비게이션 바의 이름도 설정해주기
                                            let name = document.data()["name"] as? String ?? ""
                                            let email = document.data()["email"] as? String ?? ""
                                            let subject = document.data()["subject"] as? String ?? ""
                                            
                                            self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
                                                SetQuestionDoc(self: self)
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

public func SetQuestionDoc(self : QuestionPlusViewController) {
    let db = Firestore.firestore()
    if let index = self.index {
        var studentName = ""
        var studentEmail = ""
        var teacherUid = ""
        
        db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                for document in querySnapshot!.documents {
                    studentName = document.data()["name"] as? String ?? ""
                    studentEmail = document.data()["email"] as? String ?? ""
                    self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                return
                            }
                            var teacherEmail = ""
                            for document in querySnapshot!.documents {
                                teacherEmail = document.data()["email"] as? String ?? ""
                            }
                            
                            self.db.collection("teacher").whereField("email", isEqualTo: teacherEmail).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                        return
                                    }
                                    
                                    for document in querySnapshot!.documents {
                                        teacherUid = document.data()["uid"] as? String ?? ""
                                        self.teacherUid = teacherUid
                                        guard let image = self.imageView.image else {
                                            self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").document(String(self.qnum)).setData([
                                                "imgURL":"",
                                                "title":self.name!,
                                                "questionContent": self.studyMemo,
                                                "answerCheck": false,
                                                "num":String(self.qnum)
                                            ]) { err in
                                                if let err = err {
                                                    print("Error adding document: \(err)")
                                                }
                                            }
                                            print("이미지 없음")
                                            
                                            return
                                        }
                                        
                                        if let data = image.pngData(){
                                            let urlRef = self.storageRef.child("image/\(self.file_name!).png")
                                            let metadata = StorageMetadata()
                                            metadata.contentType = "image/png"
                                            let uploadTask = urlRef.putData(data, metadata: metadata){ (metadata, error) in
                                                guard let metadata = metadata else {
                                                    return}
                                                urlRef.downloadURL { (url, error) in
                                                    guard let downloadURL = url else {
                                                        return}
                                                    
                                                    self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").document(String(self.qnum)).setData([
                                                        "imgURL":"\(downloadURL)",
                                                        "title":self.name!,
                                                        "questionContent": self.studyMemo,
                                                        "answerCheck": false,
                                                        "num": String(self.qnum)
                                                    ]) { err in
                                                        if let err = err {
                                                            print("Error adding document: \(err)")
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
                LoadingHUD.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    LoadingHUD.hide()
                }
                if let preVC = self.presentingViewController as? UIViewController {
                    preVC.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

public func UpdateAnswer(answer : String, imgtype : Int, self : AnswerViewController, imgView : UIImageView) {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var storageRef:StorageReference!
    storageRef = storage.reference()
    
    if answer == "내용이 잘 이해가 가지 않거나 모르겠는 내용을 질문해보세요." || answer == "" {
        let textalertVC = UIAlertController(title: "내용 없음", message: "질문이 있는 교재의 페이지 또는 질문 내용을 작성해주세요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        textalertVC.addAction(okAction)
        self.present(textalertVC, animated: true, completion: nil)
        print("제목 없음")
    } else {
        if imgtype == 1 {
            guard let image = imgView.image else {
                //이미지와 영상이 없는 경우
                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").document(String(self.qnum)).collection("answer").document(Auth.auth().currentUser!.uid).setData([
                    "url":"",
                    "answerContent": self.answer,
                    "isAnswer": true
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                print("image not exists")
                
                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").document(String(self.qnum)).updateData([
                    "answerCheck": true
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                
                return
            }
            
            /// image exists
            // 이미지가 있는 경우
            if let data = image.pngData(){
                let urlRef = storageRef.child("image/\(self.captureImage).png")
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
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").document(String(self.qnum)).collection("answer").document(Auth.auth().currentUser!.uid).setData([
                            "url":"\(downloadURL)",
                            "answerContent": self.answer,
                            "isAnswer": true,
                            "type":"image"
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                }
            }
        } else { //비디오의 경우
            print("video exists")
            
            if let data = NSData(contentsOf: self.videoURL as URL){
                let urlRef = storageRef.child("video/\(self.videoURL).mp4")
                
                let metadata = StorageMetadata()
                metadata.contentType = "video/mp4"
                let uploadTask = urlRef.putData(data as Data, metadata: metadata){ (metadata, error) in
                    guard let metadata = metadata else {
                        return
                    }
                    
                    urlRef.downloadURL { [self] (url, error) in
                        guard let videoURL = url else {
                            return
                        }
                        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").document(String(self.qnum)).collection("answer").document(Auth.auth().currentUser!.uid).setData([
                            "url":"\(videoURL)",
                            "answerContent": self.answer,
                            "isAnswer": true,
                            "type":"video"
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                }
                if let preVC = self.presentingViewController as? UIViewController {
                    preVC.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").document(String(self.qnum)).updateData([
        "answerCheck": true
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func GetUserInfoInQuestionView(toggleLabel : UILabel, index : Int, navigationBar : UINavigationBar, navigationBarItem : UINavigationItem, self : QuestionListViewController) {
    let db = Firestore.firestore()
    
    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    userType = "teacher"
                    toggleLabel.text = "답변 대기만 보기"
                    
                    // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let name = document.data()["name"] as? String ?? ""
                                        userName = name
                                        userEmail = document.data()["email"] as? String ?? ""
                                        userSubject = document.data()["subject"] as? String ?? ""
                                        navigationBar.topItem!.title = userName + " 학생"
                                        self.setTeacherQuestion()
                                        navigationBarItem.rightBarButtonItems?.removeAll()
                                    }
                                }
                            }
                        }
                }
            }
        }
    // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
    db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents { // 문서가 있다면
                print("\(document.documentID) => \(document.data())")
                // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                userType = "student"
                toggleLabel.text = "답변 완료만 보기"
                print ("index : \(index)")
                db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                    // 네비게이션 바의 이름도 설정해주기
                                    let name = document.data()["name"] as? String ?? ""
                                    let email = document.data()["email"] as? String ?? ""
                                    let subject = document.data()["subject"] as? String ?? ""
                                    userName = name
                                    userEmail = email
                                    userSubject = subject
                                    navigationBar.topItem!.title = name + " 선생님"
                                    db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(userName + "(" + userEmail + ") " + userSubject).collection("questionList").getDocuments() {(document, error) in
                                        self.setStudentQuestion()
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
}

public func SetQuestionList(self : QuestionListViewController) {
    let db = Firestore.firestore()
    if (userType == "teacher") {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(userName + "(" + userEmail + ") " + userSubject).collection("questionList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                
                /// 조회하기 위해 원래 있던 것 들 다 지움
                self.questionListItems.removeAll()
                self.questionAnsweredItems.removeAll()
                self.questionNotAnsweredItems.removeAll()
                
                for document in snapshot.documents {
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let questionDt = document.data()
                    
                    /// nil값 처리
                    let qnumber = questionDt["num"] as? String ?? ""
                    let title = questionDt["title"] as? String ?? ""
                    let answerCheck = questionDt["answerCheck"] as? Bool ?? false
                    let questionContent = questionDt["questionContent"] as? String ?? ""
                    let imgURL = questionDt["imgURL"] as? String ?? ""
                    let email = questionDt["email"] as? String ?? ""
                    
                    
                    if Int(qnumber)! > self.maxnum {
                        self.maxnum = Int(qnumber)!
                    }
                    
                    print("가장 큰 값 : \(self.maxnum)")
                    
                    let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL , questionContent: questionContent, email: email, index: qnumber )
                    
                    let answeredItem = QuestionAnsweredListItem(title: title, answerCheck: answerCheck, imgURL: imgURL, questionContent: questionContent, email: email, index: qnumber)
                    
                    /// 모든 값을 더한다.
                    /// 전체 경우
                    self.questionListItems.append(item)
                    
                    /// 답변 완료일 경우
                    if answerCheck == true {
                        self.questionAnsweredItems.append(answeredItem)
                    } else if answerCheck == false {
                        self.questionNotAnsweredItems.append(answeredItem)
                    }
                }
                
                /// UITableView를 reload 하기
                self.questionListTV.reloadData()
            }
        }
    } else {
        if let index = self.index {
            var studentName = ""
            var studentEmail = ""
            var teacherUid = ""
            
            db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                    self.showDefaultAlert(msg: "질문을 찾는 중 에러가 발생했습니다.")
                } else {
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    for document in querySnapshot!.documents {
                        studentName = document.data()["name"] as? String ?? ""
                        
                        self.sname = studentName
                        studentEmail = document.data()["email"] as? String ?? ""
                        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                                self.showDefaultAlert(msg: "질문을 찾는 중 에러가 발생했습니다.")
                            } else {
                                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                    return
                                }
                                var teacherEmail = ""
                                for document in querySnapshot!.documents {
                                    teacherEmail = document.data()["email"] as? String ?? ""
                                }
                                
                                db.collection("teacher").whereField("email", isEqualTo: teacherEmail).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                        self.showDefaultAlert(msg: "질문을 찾는 중 에러가 발생했습니다.")
                                    } else {
                                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                            return
                                        }
                                        
                                        for document in querySnapshot!.documents {
                                            teacherUid = document.data()["uid"] as? String ?? ""
                                            self.teacherUid = teacherUid
                                            
                                            db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + userSubject).collection("questionList").getDocuments() { (querySnapshot, err) in
                                                if let err = err {
                                                    print(">>>>> document 에러 : \(err)")
                                                    self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                                                } else {
                                                    /// nil이 아닌지 확인한다.
                                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                        return
                                                    }
                                                    
                                                    /// 조회하기 위해 원래 있던 것 들 다 지움
                                                    self.questionListItems.removeAll()
                                                    self.questionAnsweredItems.removeAll()
                                                    self.questionNotAnsweredItems.removeAll()
                                                    
                                                    for document in snapshot.documents {
                                                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                        let questionDt = document.data()
                                                        
                                                        /// nil값 처리
                                                        let qnumber = questionDt["num"] as? String ?? ""
                                                        let title = questionDt["title"] as? String ?? ""
                                                        let answerCheck = questionDt["answerCheck"] as? Bool ?? false
                                                        let questionContent = questionDt["questionContent"] as? String ?? ""
                                                        let imgURL = questionDt["imgURL"] as? String ?? ""
                                                        let email = questionDt["email"] as? String ?? ""
                                                        
                                                        let qnum = Int(qnumber)!
                                                        self.maxnum = 0
                                                        if qnum > self.maxnum {
                                                            self.maxnum = qnum
                                                        }
                                                        print("가장 큰 값 : \(self.maxnum)")
                                                        
                                                        if (qnumber != "" && title != "" && questionContent != ""){
                                                            let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL , questionContent: questionContent, email: email, index: qnumber )
                                                            
                                                            let answeredItem = QuestionAnsweredListItem(title: title, answerCheck: answerCheck, imgURL: imgURL, questionContent: questionContent, email: email, index: qnumber)
                                                            
                                                            /// 모든 값을 더한다.
                                                            /// 전체 경우
                                                            self.questionListItems.append(item)
                                                            print (self.questionListItems)
                                                            /// 답변 완료일 경우
                                                            if answerCheck == true {
                                                                self.questionAnsweredItems.append(answeredItem)
                                                                print (self.questionAnsweredItems)
                                                            } else if answerCheck == false {
                                                                self.questionNotAnsweredItems.append(answeredItem)
                                                                print (self.questionNotAnsweredItems)
                                                            }
                                                            
                                                        }
                                                    }
                                                    /// UITableView를 reload 하기
                                                    self.questionListTV.reloadData()
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
    }
}

public func GetUserInfoInQuestionVC (self : QuestionViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러(inQuestionVC) : \(err)")
        } else {
            if let err = err {
                print("Error getting documents(inQuestionVC): \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    userType = document.data()["type"] as? String ?? ""
                    userEmail = document.data()["email"] as? String ?? ""
                    userName = document.data()["name"] as? String ?? ""
                    let userProfile = document.data()["profile"] as? String ?? ""
                    let url = URL(string: userProfile)!
                    self.teacherImage.kf.setImage(with: url)
                    self.teacherImage.makeCircle()
                    self.setTeacherInfo()
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
                    userType = type
                    let userProfile = document.data()["profile"] as? String ?? ""
                    let url = URL(string: userProfile)!
                    self.teacherImage.kf.setImage(with: url)
                    self.teacherImage.makeCircle()
                    self.setStudentInfo()
                }
            }
        }
    }
}

public func SetQuestionRoom (self : QuestionViewController) {
    let db = Firestore.firestore()
    
    // 선생님일 경우
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
            self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
        } else {
            /// nil이 아닌지 확인한다.
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                        self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                    } else {
                        /// nil이 아닌지 확인한다.
                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                            return
                        }
                        
                        /// 조회하기 위해 원래 있던 것 들 다 지움
                        self.questionItems.removeAll()
                        
                        for document in snapshot.documents {
                            print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                            
                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                            let classDt = document.data()
                            let name = classDt["name"] as? String ?? ""
                            userName = name
                            let subject = classDt["subject"] as? String ?? ""
                            userSubject = subject
                            let classColor = classDt["circleColor"] as? String ?? "026700"
                            let email = classDt["email"] as? String ?? ""
                            userEmail = email
                            let index = classDt["index"] as? Int ?? 0
                            
                            let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email, index: index)
                            
                            /// 모든 값을 더한다.
                            self.questionItems.append(item)
                        }
                        
                        /// UITableView를 reload 하기
                        self.questionTV.reloadData()
                    }
                }
                return
            }
            
            /// 조회하기 위해 원래 있던 것 들 다 지움
            self.questionItems.removeAll()
            
            
            for document in snapshot.documents {
                print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                
                /// document.data()를 통해서 값 받아옴, data는 dictionary
                let classDt = document.data()
                /// nil값 처리
                let name = classDt["name"] as? String ?? ""
                userName = name
                let subject = classDt["subject"] as? String ?? ""
                userSubject = subject
                let classColor = classDt["circleColor"] as? String ?? "026700"
                self.classColor = classColor
                let email = classDt["email"] as? String ?? ""
                userEmail = email
                let index = classDt["index"] as? Int ?? 0
                
                let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email, index: index)
                
                /// 모든 값을 더한다.
                self.questionItems.append(item)
            }
            
            /// UITableView를 reload 하기
            self.questionTV.reloadData()
        }
        return
    }
    
    // 학생일 경우
    db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
            self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
        } else {
            /// nil이 아닌지 확인한다.
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                        self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                    } else {
                        /// nil이 아닌지 확인한다.
                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                            return
                        }
                        
                        /// 조회하기 위해 원래 있던 것 들 다 지움
                        self.questionItems.removeAll()
                        
                        for document in snapshot.documents {
                            print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                            let classDt = document.data()
                            // nil 값 처리
                            let name = classDt["name"] as? String ?? ""
                            userName = name
                            let subject = classDt["subject"] as? String ?? ""
                            userSubject = subject
                            let classColor = classDt["circleColor"] as? String ?? "026700"
                            let email = classDt["email"] as? String ?? ""
                            userEmail = email
                            let index = classDt["index"] as? Int ?? 0
                            self.index = index
                            
                            let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email, index: index)
                            
                            /// 모든 값을 더한다.
                            self.questionItems.append(item)
                        }
                        
                        /// UITableView를 reload 하기
                        self.questionTV.reloadData()
                    }
                }
                return
            }
            
            /// 조회하기 위해 원래 있던 것 들 다 지움
            self.questionItems.removeAll()
            
            for document in snapshot.documents {
                print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                
                /// document.data()를 통해서 값 받아옴, data는 dictionary
                let classDt = document.data()
                /// nil값 처리
                let name = classDt["name"] as? String ?? ""
                userName = name
                let subject = classDt["subject"] as? String ?? ""
                userSubject = subject
                let classColor = classDt["circleColor"] as? String ?? "026700"
                self.classColor = classColor
                let email = classDt["email"] as? String ?? ""
                userEmail = email
                let index = classDt["index"] as? Int ?? 0
                
                let item = QuestionItem(userName : name, subjectName : subject, classColor: classColor, email: email, index: index)
                
                /// 모든 값을 더한다.
                self.questionItems.append(item)
            }
            
            /// UITableView를 reload 하기
            self.questionTV.reloadData()
        }
        return
    }
}

public func QuestionCellClicked(self : QuestionViewController, indexPath : IndexPath) {
    let docRef : CollectionReference!
    let db = Firestore.firestore()
    
    // 사용자 구별
    if userType == "teacher" {
        docRef = db.collection("teacher")
    } else {
        docRef = db.collection("student")
    }
    
    var index: Int!
    var name: String!
    var email: String!
    var subject: String!
    var type: String!
    
    let currentCell = self.questionTV.cellForRow(at: indexPath)
    
    docRef.document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: currentCell?.contentView.tag)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionListViewController") as? QuestionListViewController else { return }
                
                questionVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                questionVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                /// first : 여러개가 와도 첫번째 것만 봄.
                
                let questionDt = snapshot.documents.first!.data()
                
                index = questionDt["index"] as? Int ?? 0
                name = questionDt["name"] as? String ?? ""
                subject = questionDt["subject"] as? String ?? ""
                email = questionDt["email"] as? String ?? ""
                type = questionDt["type"] as? String ?? ""
                
                questionVC.index = index
                questionVC.email = email
                questionVC.name = name
                questionVC.type = type
                questionVC.subject = subject
                
                self.present(questionVC, animated: true, completion: nil)
            }
        }
    if (userType == "teacher"){
        guard let questionListVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionListViewController") as? QuestionListViewController else { return }
        
        questionListVC.modalPresentationStyle = .fullScreen
        questionListVC.modalTransitionStyle = .crossDissolve
        
        questionListVC.email = email
        questionListVC.subject = subject
        questionListVC.name = name
        questionListVC.type = "teacher"
        questionListVC.index = currentCell?.contentView.tag
        
        self.present(questionListVC, animated: true, completion: nil)
    }
}

public func GetUserInfoInQuestionDetailVC (self : QuestionDetailViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    self.type = "teacher"
                    
                    if let index = self.index { // userIndex가 nil이 아니라면
                        // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                        print ("index : \(index)")
                        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                            // 네비게이션 바의 이름도 설정해주기
                                            let name = document.data()["name"] as? String ?? ""
                                            self.userName = name
                                            self.email = document.data()["email"] as? String ?? ""
                                            self.subject = document.data()["subject"] as? String ?? ""
                                            
                                            self.navigationBar.topItem!.title = self.userName + " 학생"
                                            
                                            self.setQuestion()
                                        }
                                    }
                                }
                            }
                    }
                }
            }
        }
    
    db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    
                    if let index = self.index { // userIndex가 nil이 아니라면
                        // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                        self.type = "student"
                        print ("index : \(index)")
                        self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                            // 네비게이션 바의 이름도 설정해주기
                                            let name = document.data()["name"] as? String ?? ""
                                            let email = document.data()["email"] as? String ?? ""
                                            let subject = document.data()["subject"] as? String ?? ""
                                            
                                            self.navigationBar.topItem!.title = name + " 선생님"
                                            
                                            self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
                                                self.setQuestion()
                                                self.answerBtn.removeFromSuperview()
                                                self.answerBtn.backgroundColor = .white
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

public func SetQuestion(self : QuestionDetailViewController) {
    let db = Firestore.firestore()
    if (self.type == "teacher") {
        if let qnum = self.qnum {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").whereField("num", isEqualTo: String(qnum)).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                    
                } else {
                    /// nil이 아닌지 확인한다.
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    
                    for document in snapshot.documents {
                        print(">>>>> 자세한 document 정보 : \(document.documentID) => \(document.data())")
                        
                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                        let questionDt = document.data()
                        /// nil값 처리
                        let title = questionDt["title"] as? String ?? ""
                        let questionContent = questionDt["questionContent"] as? String ?? ""
                        let imgURL = questionDt["imgURL"] as? String ?? ""
                        
                        self.titleName.text = title
                        self.questionContent.text = questionContent
                        if imgURL != "" {
                            let url = URL(string: imgURL)
                            DispatchQueue.global().async {
                                let data = try? Data(contentsOf: url!)
                                DispatchQueue.main.async {
                                    self.imgView.image = UIImage(data: data!)
                                }
                            }
                        } else if (imgURL == "") {
                            self.imgView.removeFromSuperview()
                        }
                        self.questionContent.translatesAutoresizingMaskIntoConstraints = true
                        self.questionContent.sizeToFit()
                        self.questionContent.isScrollEnabled = false
                    }
                }
            }
        }
    } else {
        if let index = self.index {
            var studentName = ""
            var studentEmail = ""
            var teacherUid = ""
            
            db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                    
                } else {
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    for document in querySnapshot!.documents {
                        studentName = document.data()["name"] as? String ?? ""
                        studentEmail = document.data()["email"] as? String ?? ""
                        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                                
                            } else {
                                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                    return
                                }
                                var teacherEmail = ""
                                for document in querySnapshot!.documents {
                                    teacherEmail = document.data()["email"] as? String ?? ""
                                }
                                
                                db.collection("teacher").whereField("email", isEqualTo: teacherEmail).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                        
                                    } else {
                                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                            return
                                        }
                                        
                                        for document in querySnapshot!.documents {
                                            teacherUid = document.data()["uid"] as? String ?? ""
                                            self.teacherUid = teacherUid
                                            print ("TeacherUID : \(teacherUid)")
                                            
                                            db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").whereField("num", isEqualTo: String(self.qnum)).getDocuments() { (querySnapshot, err) in
                                                if let err = err {
                                                    print(">>>>> document 에러 : \(err)")
                                                } else {
                                                    /// nil이 아닌지 확인한다.
                                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                        return
                                                    }
                                                    
                                                    for document in snapshot.documents {
                                                        print(">>>>> 자세한 document 정보 : \(document.documentID) => \(document.data())")
                                                        
                                                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                        let questionDt = document.data()
                                                        /// nil값 처리
                                                        let title = questionDt["title"] as? String ?? ""
                                                        let questionContent = questionDt["questionContent"] as? String ?? ""
                                                        let imgURL = questionDt["imgURL"] as? String ?? ""
                                                        
                                                        self.titleName.text = title
                                                        self.questionContent.text = questionContent
                                                        if imgURL != "" {
                                                            let url = URL(string: imgURL)
                                                            DispatchQueue.global().async {
                                                                let data = try? Data(contentsOf: url!)
                                                                DispatchQueue.main.async {
                                                                    self.imgView.image = UIImage(data: data!)
                                                                }
                                                            }
                                                        } else if (imgURL == "") {
                                                            self.imgView.removeFromSuperview()
                                                        }
                                                        
                                                        self.questionContent.translatesAutoresizingMaskIntoConstraints = true
                                                        self.questionContent.sizeToFit()
                                                        self.questionContent.isScrollEnabled = false
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
        }
    }
    return
}

public func GetUserInfoInQnADetailVC (self : QnADetailViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    self.type = "teacher"
                    
                    if let index = self.index { // userIndex가 nil이 아니라면
                        // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                        print ("index : \(index)")
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                            // 네비게이션 바의 이름도 설정해주기
                                            let name = document.data()["name"] as? String ?? ""
                                            self.userName = name
                                            self.email = document.data()["email"] as? String ?? ""
                                            self.subject = document.data()["subject"] as? String ?? ""
                                            self.subjectName.text = self.subject
                                            self.navigationBar.topItem!.title = self.userName + " 학생"
                                            self.setQnA()
                                        }
                                    }
                                }
                            }
                    }
                }
            }
        }
    
    db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { // 문서가 있다면
                    print("\(document.documentID) => \(document.data())")
                    
                    if let index = self.index { // userIndex가 nil이 아니라면
                        // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                        self.type = "student"
                        print ("index : \(index)")
                        self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                            // 네비게이션 바의 이름도 설정해주기
                                            let name = document.data()["name"] as? String ?? ""
                                            let email = document.data()["email"] as? String ?? ""
                                            let subject = document.data()["subject"] as? String ?? ""
                                            self.subjectName.text = subject
                                            self.navigationBar.topItem!.title = name + " 선생님"
                                            
                                            self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
                                                self.setQnA()
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

public func SetQnA (self : QnADetailViewController) {
    let db = Firestore.firestore()
    if (self.type == "teacher") {
        if let qnum = self.qnum, let userName = self.userName, let userEmail = self.email, let subject = self.subject {
            //답변 내용
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(userName + "(" + userEmail + ") " + subject).collection("questionList").document("\(qnum)").collection("answer").whereField("isAnswer", isEqualTo: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    /// nil이 아닌지 확인한다.
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    for document in snapshot.documents {
                        print(">>>>> 답변 document 정보 : \(document.documentID) => \(document.data())")
                        
                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                        let questionDt = document.data()
                        
                        let answer = questionDt["answerContent"] as? String ?? ""
                        let imgurl = questionDt["url"] as? String ?? ""
                        let imgType = questionDt["type"] as? String ?? ""
                        
                        self.answerContent.text = answer
                        self.answerContent.translatesAutoresizingMaskIntoConstraints = true
                        self.answerContent.sizeToFit()
                        self.answerContent.isScrollEnabled = false
                        
                        if (imgurl == "" || imgurl == "nil") {
                            if (self.answerImgView != nil) {
                                self.answerImgView.image = .none
                                self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + 50)
                                    .isActive = true
                            }
                        } else {
                            if imgType == "image"{
                                let url = URL(string: imgurl)
                                DispatchQueue.global().async {
                                    let data = try? Data(contentsOf: url!)
                                    DispatchQueue.main.async {
                                        if (self.answerImgView != nil) {
                                            self.answerImgView.image = UIImage(data: data!)
                                            self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + self.answerImgView.frame.height + 50)
                                                .isActive = true
                                        }
                                    }
                                }
                            } else {
                                let url = URL(string: imgurl)
                                self.player = AVPlayer(url: url!)
                                self.avPlayerLayer = AVPlayerLayer(player: self.player)
                                self.avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
                                self.videourl = url
                                self.answerImgView.layer.addSublayer(self.avPlayerLayer)
                            }
                        }
                    }
                }
            }
            
            //질문 내용
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(userName + "(" + userEmail + ") " + subject).collection("questionList").whereField("num", isEqualTo: "\(qnum)").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    /// nil이 아닌지 확인한다.
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    for document in snapshot.documents {
                        print(">>>>> 질문 document 정보 : \(document.documentID) => \(document.data())")
                        
                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                        let questionDt = document.data()
                        
                        /// nil값 처리
                        let title = questionDt["title"] as? String ?? ""
                        let questionContent = questionDt["questionContent"] as? String ?? ""
                        let imgURL = questionDt["imgURL"] as? String ?? ""
                        let num = questionDt["num"] as? String ?? ""
                        
                        self.titleName.text = title
                        self.questionContent.text = questionContent
                        self.questionContent.translatesAutoresizingMaskIntoConstraints = true
                        self.questionContent.sizeToFit()
                        self.questionContent.isScrollEnabled = false
                        
                        if imgURL != "" {
                            let url = URL(string: imgURL)
                            DispatchQueue.global().async {
                                let data = try? Data(contentsOf: url!)
                                DispatchQueue.main.async {
                                    self.questionImgView.image = UIImage(data: data!)
                                    self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + self.questionImgView.frame.height + 50)
                                        .isActive = true
                                }
                            }
                        } else if (imgURL == "") {
                            self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + 50)
                                .isActive = true
                        }
                    }
                }
            }
        }
        
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingHUD.hide()
        }
    } else { //학생이면
        if let index = self.index {
            var studentName = ""
            var studentEmail = ""
            var teacherUid = ""
            
            db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                    
                } else {
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    for document in querySnapshot!.documents {
                        studentName = document.data()["name"] as? String ?? ""
                        studentEmail = document.data()["email"] as? String ?? ""
                        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                                
                            } else {
                                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                    return
                                }
                                var teacherEmail = ""
                                for document in querySnapshot!.documents {
                                    teacherEmail = document.data()["email"] as? String ?? ""
                                }
                                
                                db.collection("teacher").whereField("email", isEqualTo: teacherEmail).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                        
                                    } else {
                                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                            return
                                        }
                                        
                                        for document in querySnapshot!.documents {
                                            teacherUid = document.data()["uid"] as? String ?? ""
                                            self.teacherUid = teacherUid
                                            print ("TeacherUID : \(teacherUid)")
                                            //질문 내용
                                            db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").whereField("num", isEqualTo: String(self.qnum!)).getDocuments() { (querySnapshot, err) in
                                                if let err = err {
                                                    print(">>>>> document 에러 : \(err)")
                                                } else {
                                                    /// nil이 아닌지 확인한다.
                                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                        return
                                                    }
                                                    
                                                    for document in snapshot.documents {
                                                        print(">>>>> 자세한 document 정보 : \(document.documentID) => \(document.data())")
                                                        
                                                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                        let questionDt = document.data()
                                                        
                                                        /// nil값 처리
                                                        let title = questionDt["title"] as? String ?? ""
                                                        let questionContent = questionDt["questionContent"] as? String ?? ""
                                                        let imgURL = questionDt["imgURL"] as? String ?? ""
                                                        
                                                        self.titleName.text = title
                                                        self.questionContent.text = questionContent
                                                        self.questionContent.translatesAutoresizingMaskIntoConstraints = true
                                                        self.questionContent.sizeToFit()
                                                        self.questionContent.isScrollEnabled = false
                                                        
                                                        if imgURL != "" {
                                                            let url = URL(string: imgURL)
                                                            DispatchQueue.global().async {
                                                                let data = try? Data(contentsOf: url!)
                                                                DispatchQueue.main.async {
                                                                    self.questionImgView.image = UIImage(data: data!)
                                                                    self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + self.questionImgView.frame.height + 50)
                                                                        .isActive = true
                                                                    
                                                                }
                                                            }
                                                        } else if (imgURL == "") {
                                                            self.answerImgView.removeFromSuperview()
                                                            self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + 50)
                                                                .isActive = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        //답변 내용
                                        self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").document(String(self.qnum!)).collection("answer").whereField("isAnswer", isEqualTo: true).getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print(">>>>> document 에러 : \(err)")
                                            } else {
                                                /// nil이 아닌지 확인한다.
                                                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                    return
                                                }
                                                
                                                for document in snapshot.documents {
                                                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                                                    
                                                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                    let questionDt = document.data()
                                                    
                                                    let answer = questionDt["answerContent"] as? String ?? ""
                                                    let imgurl = questionDt["url"] as? String ?? ""
                                                    let imgType = questionDt["type"] as? String ?? ""
                                                    
                                                    self.answerContent.text = answer
                                                    self.answerContent.translatesAutoresizingMaskIntoConstraints = true
                                                    self.answerContent.sizeToFit()
                                                    self.answerContent.isScrollEnabled = false
                                                    
                                                    if (imgurl == "" || imgurl == "nil") {
                                                        if (self.answerImgView != nil) {
                                                            self.answerImgView.image = .none
                                                            self.answerImgView.removeFromSuperview()
                                                            self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + 50)
                                                                .isActive = true
                                                        }
                                                    } else {
                                                        if imgType == "image"{
                                                            let url = URL(string: imgurl)
                                                            DispatchQueue.global().async {
                                                                let data = try? Data(contentsOf: url!)
                                                                DispatchQueue.main.async {
                                                                    if (self.answerImgView != nil) {
                                                                        self.answerImgView.image = UIImage(data: data!)
                                                                        self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + self.answerImgView.frame.height + 50)
                                                                            .isActive = true
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let url = URL(string: imgurl)
                                                            self.player = AVPlayer(url: url!)
                                                            self.avPlayerLayer = AVPlayerLayer(player: self.player)
                                                            self.avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
                                                            self.videourl = url
                                                            self.answerImgView.layer.addSublayer(self.avPlayerLayer)
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
            }
        }
    }
}
