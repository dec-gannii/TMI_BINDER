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
