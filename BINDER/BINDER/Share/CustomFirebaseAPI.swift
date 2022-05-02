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

public var linkBtnEmail : String = ""
public var linkBtnIndex : Int = 0
public var linkBtnSubject : String = ""
public var linkBtnName : String = ""
public var userType : String = ""
//public var userName : String = ""
public var userEmail : String = ""
public var userPW : String = ""

public var sharedEvents : [Date] = []
public var sharedDays : [Date] = []

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
