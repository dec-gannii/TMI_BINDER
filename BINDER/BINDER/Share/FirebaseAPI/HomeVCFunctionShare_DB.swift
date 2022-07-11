//
//  HomeVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit
import FSCalendar

var count = 0

struct HomeVCDBFunctions {
    func GetTeacherMyClass(self : HomeViewController) {
        count = 0
        self.linkTypeLabel.text = "학생 바로가기"
        
        let labels = [self.HomeStudentIconLabel, self.HomeStudentIconSecondLabel, self.HomeStudentIconThirdLabel]
        let buttons = [self.firstLinkBtn, self.secondLinkBtn, self.thirdLinkBtn]
        let subjectLabels = [self.homeStudentClassTxt2, self.homeStudentClassTxt3, self.homeStudentClassTxt]
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.linkTypeLabel.text = "학생 바로가기"
                    print("\(document.documentID) => \(document.data())")
                    if ((querySnapshot?.documents.count)! >= 3) {
                        if count <= 2 {
                            let infoData = document.data()
                            let name = infoData["name"] as? String ?? ""
                            let subject = infoData["subject"] as? String ?? ""
                            labels[count]!.text = name
                            buttons[count]!.isHidden = false
                            labels[count]!.isHidden = false
                            subjectLabels[count]!.text = subject
                            subjectLabels[count]!.isHidden = false
                            count = count + 1
                        }
                    } else {
                        if count < (querySnapshot?.documents.count)! {
                            let infoData = document.data()
                            let name = infoData["name"] as? String ?? ""
                            let subject = infoData["subject"] as? String ?? ""
                            labels[count]!.text = name
                            buttons[count]!.isHidden = false
                            labels[count]!.isHidden = false
                            subjectLabels[count]!.text = subject
                            subjectLabels[count]!.isHidden = false
                            count = count + 1
                        }
                    }
                    continue
                }
            }
        }
    }
    
    func GetStudentMyClass(self : HomeViewController) {
        count = 0
        self.linkTypeLabel.text = "선생님 바로가기"
        
        let labels = [self.HomeStudentIconLabel, self.HomeStudentIconSecondLabel, self.HomeStudentIconThirdLabel]
        let buttons = [self.firstLinkBtn, self.secondLinkBtn, self.thirdLinkBtn]
        let subjectLabels = [self.homeStudentClassTxt2, self.homeStudentClassTxt3, self.homeStudentClassTxt]
        
        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.linkTypeLabel.text = "선생님 바로가기"
                    print("\(document.documentID) => \(document.data())")
                    if ((querySnapshot?.documents.count)! >= 3) {
                        if count <= 2 {
                            let infoData = document.data()
                            let name = infoData["name"] as? String ?? ""
                            let subject = infoData["subject"] as? String ?? ""
                            let index = infoData["index"] as? Int ?? 0
                            labels[count]!.text = name
                            buttons[count]!.isHidden = false
                            labels[count]!.isHidden = false
                            subjectLabels[count]!.text = subject
                            subjectLabels[count]!.isHidden = false
                            count = count + 1
                        }
                    } else {
                        if count < (querySnapshot?.documents.count)! {
                            let infoData = document.data()
                            let name = infoData["name"] as? String ?? ""
                            let subject = infoData["subject"] as? String ?? ""
                            labels[count]!.text = name
                            buttons[count]!.isHidden = false
                            labels[count]!.isHidden = false
                            subjectLabels[count]!.text = subject
                            subjectLabels[count]!.isHidden = false
                            count = count + 1
                        }
                    }
                    continue
                }
            }
        }
    }
    
    func GetTeacherEvents(events : [Date], days : [Date], self : HomeViewController) {
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
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
                    
                    let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("schedule").document(datestr).collection("scheduleList")
                    
                    docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                let data = document.data()
                                let date = data["date"] as? String ?? ""
                                
                                formatter.dateFormat = "YYYY-MM-dd"
                                let date_d = formatter.date(from: date)!
                                sharedEvents.append(date_d)
                            }
                            self.eventCountTxt.text = "\(sharedEvents.count)개의 일정"
                            self.calendarView.reloadData()
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func GetStudentEvents(events : [Date], days : [Date], self : HomeViewController) {
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
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
                    
                    let docRef = db.collection("student").document(Auth.auth().currentUser!.uid).collection("schedule").document(datestr).collection("scheduleList")
                    
                    docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                let data = document.data()
                                let date = data["date"] as? String ?? ""
                                
                                formatter.dateFormat = "YYYY-MM-dd"
                                let date_d = formatter.date(from: date)!
                                sharedEvents.append(date_d)
                            }
                            self.eventCountTxt.text = "\(sharedEvents.count)개의 일정"
                            self.calendarView.reloadData()
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func GetTeacherInfo(days : [Date], homeStudentScrollView : UIScrollView, stateLabel : UILabel, self: HomeViewController) {
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let type = data?["type"] as? String ?? ""
                let email = data?["email"] as? String ?? ""
                let pw = data?["password"] as? String ?? ""
                let profile = data?["profile"] as? String ?? ""
                let uid = data?["uid"] as? String ?? Auth.auth().currentUser?.uid
                
                userEmail = email
                userPW = pw
                
                LoginRepository.shared.teacherItem = TeacherItem(email: email, name: name, password: pw, profile: profile, type: type, uid: uid!)
                
                self.id = LoginRepository.shared.teacherItem!.email
                self.pw = LoginRepository.shared.teacherItem!.password
                self.type = LoginRepository.shared.teacherItem!.type
                
                stateLabel.text = LoginRepository.shared.teacherItem!.name + " 선생님 환영합니다!"
                if (Auth.auth().currentUser?.email == (data?["email"] as! String)) {
                    userType = "teacher"
                } else {
                    userType = type
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
                    
                    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(datestr).collection("scheduleList").whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                // 사용할 것들 가져와서 지역 변수로 저장
                                let data = document.data()
                                let date = data["date"] as? String ?? ""
                                
                                formatter.dateFormat = "YYYY-MM-dd"
                                let date_d = formatter.date(from: date)!
                                
                                sharedEvents.append(date_d)
                                self.calendarView.reloadData()
                            }
                            
                            self.eventCountTxt.text = "\(sharedEvents.count)개의 일정"
                        }
                    }
                }
                homeStudentScrollView.isHidden = false
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func GetStudentInfo(days : [Date], homeStudentScrollView : UIScrollView, stateLabel : UILabel, self: HomeViewController) {
        db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let name = data?["name"] as? String ?? ""
                let type = data?["type"] as? String ?? ""
                let email = data?["email"] as? String ?? ""
                let pw = data?["password"] as? String ?? ""
                let profile = data?["profile"] as? String ?? ""
                let phonenum = data?["phonenum"] as? String ?? ""
                let uid = data?["uid"] as? String ?? ""
                let goal = data?["goal"] as? String ?? ""
                
                userEmail = email
                userPW = pw
                
                LoginRepository.shared.studentItem = StudentItem(email: email, goal: goal, name: name, password: pw, phone: phonenum, profile: profile, type: type, uid: uid)
                
                self.id = LoginRepository.shared.studentItem!.email
                self.pw = LoginRepository.shared.studentItem!.password
                self.type = LoginRepository.shared.studentItem!.type
                
                stateLabel.text = LoginRepository.shared.studentItem!.name + " 학생 환영합니다!"
                
                if (Auth.auth().currentUser?.email == (data?["email"] as! String)) {
                    userType = "student"
                } else {
                    userType = type
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
                                let data = document.data()
                                // 사용할 것들 가져와서 지역 변수로 저장
                                let date = data["date"] as? String ?? ""
                                formatter.dateFormat = "YYYY-MM-dd"
                                let date_d = formatter.date(from: date)!
                                
                                sharedEvents.append(date_d)
                                self.calendarView.reloadData()
                            }
                            self.eventCountTxt.text = "\(sharedEvents.count)개의 일정"
                        }
                    }
                }
                homeStudentScrollView.isHidden = false
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func ShowScheduleList(date : String, scheduleListVC : ScheduleListViewController, self : HomeViewController) {
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
    
    func GetLinkButtonInfos(sender : UIButton, firstLabel : UILabel, secondLabel : UILabel, thirdLabel : UILabel, detailVC : MyClassDetailViewController, self : HomeViewController) {
        let labels = [self.HomeStudentIconLabel, self.HomeStudentIconSecondLabel, self.HomeStudentIconThirdLabel]
        let subjectLabels = [self.homeStudentClassTxt2, self.homeStudentClassTxt3, self.homeStudentClassTxt]
        
        if (userType == "teacher") {
            // 설정해둔 버튼의 태그에 따라서 레이블의 이름을 가지고 비교 후 학생 관리 페이지로 넘어가기
            linkBtnName = labels[(sender as AnyObject).tag]!.text!
            linkBtnSubject = subjectLabels[(sender as AnyObject).tag]!.text!
            
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("name", isEqualTo: linkBtnName).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        // 사용할 것들 가져와서 지역 변수로 저장
                        let data = document.data()
                        linkBtnEmail = data["email"] as? String ?? ""
                        let subject = data["subject"] as? String ?? ""
                        if (linkBtnSubject != subject) {
                            continue
                        } else {
                            linkBtnIndex = data["index"] as? Int ?? 0
                        }
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
            linkBtnName = labels[(sender as AnyObject).tag]!.text!
            linkBtnSubject = subjectLabels[(sender as AnyObject).tag]!.text!
            
            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("name", isEqualTo: linkBtnName).getDocuments() { (querySnapshot, err) in
                if let err = err { print("Error getting documents: \(err)") }
                else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        // 사용할 것들 가져와서 지역 변수로 저장
                        let data = document.data()
                        linkBtnEmail = data["email"] as? String ?? ""
                        let subject = data["subject"] as? String ?? ""
                        if (linkBtnSubject != subject) {
                            continue
                        } else {
                            linkBtnIndex = data["index"] as? Int ?? 0
                        }
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
}
