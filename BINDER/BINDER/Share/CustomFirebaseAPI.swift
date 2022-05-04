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
