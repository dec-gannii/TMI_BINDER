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

public var userType : String = ""
public var userName : String = ""
public var userEmail : String = ""
public var userSubject : String = ""

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
