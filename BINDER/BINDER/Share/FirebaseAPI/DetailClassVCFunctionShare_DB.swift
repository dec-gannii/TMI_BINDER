//
//  DetailClassVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit
import FSCalendar

struct DetailClassDBFunctions {
    let notification = PushNotificationSender()
    
    func SaveMonthlyEvaluation(self : DetailClassViewController) {
        let date = self.selectedMonth + "월"
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument {(document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let teacherName = data!["name"] as? String ?? ""
                let teacherEmail = data!["email"] as? String ?? ""
                
                if let email = self.userEmail {
                    db.collection("student").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let uid = document.data()["uid"] as? String ?? ""
                                
                                db.collection("student").document(uid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).collection("Evaluation").document(date).setData([
                                    "month": date,
                                    "isMonthlyEvaluation": true,
                                    "evaluation": self.monthlyEvaluationTextView.text!
                                ]) { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    }
                                }
                            }
                            notification.sendPushNotification(token: self.fcmToken, title: "입금 기간이에요!", body: "\(self.tname!) 선생님께 교육비를 입금해주세요.")
                        }
                    }
                }
            }
        }
    }
    
    func DeleteClass (self : MyClassDetailViewController) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).delete()
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument {(document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let teacherName = data!["name"] as? String ?? ""
                let teacherEmail = data!["email"] as? String ?? ""
                if let email = self.userEmail {
                    let studentPath = db.collection("student").whereField("email", isEqualTo: email)
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
    
    func SaveDailyEvaluation(self : DetailClassViewController) {
        // 경로는 각 학생의 class의 Evaluation
        if(self.userType == "teacher") {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                "recentDate": self.date
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            
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
                        if self.classTimeTextField.text == nil {
                            self.classTimeTextField.text = "2"
                        }
                        if (currentCnt+Int(self.classTimeTextField.text!)! >= 8) {
                            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                                "currentCnt": (currentCnt + Int(self.classTimeTextField.text!)!) % 8
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        } else {
                            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                                "currentCnt": currentCnt + Int(self.classTimeTextField.text!)!
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        }
                        count = currentCnt + Int(self.classTimeTextField.text!)!
                    } else if (payType == "C") {
                        if ((currentCnt+1) >= 8) {
                            currentCnt = currentCnt % 8
                            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                                "currentCnt": currentCnt + 1
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        } else {
                            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
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
                                        db.collection("student").document(uid).collection("class").document(path).updateData([
                                            "currentCnt": count,
                                        ]) { err in
                                            if let err = err {
                                                print("Error adding document: \(err)")
                                            }
                                        }
                                    }
                                }
                            }
                            self.currentCnt = count
                        }
                    }
                } else {
                    print("버튼 클릭 후 Document does not exist")
                }
            }
            self.evaluationView.isHidden = true
            self.evaluationOKBtn.isHidden = true
        } else if (self.userType == "student") {
            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
                "recentDate": self.date
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
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
    
    func GetEvaluations(self : DetailClassViewController, dateStr : String) {
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
                    self.placeholderSetting(self.progressTextView)
                } else {
                    print("Document does not exist")
                    // 값 다시 공백 설정
                    self.resetTextFields()
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
                                    if let selectedMonth = self.selectedMonth {
                                        db.collection("student").document(studentUid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).collection("Evaluation").document(selectedMonth + "월").getDocument(){ (document, error) in
                                            if let document = document, document.exists {
                                                let data = document.data()
                                                let evaluation = data!["evaluation"] as? String ?? ""
                                                self.monthlyEvaluationTextView.text = evaluation
                                                self.placeholderSetting(self.monthlyEvaluationTextView)
                                            } else {
                                                self.monthlyEvaluationTextView.text = ""
                                                self.placeholderSetting(self.monthlyEvaluationTextView)
                                            }
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
            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).collection("Evaluation").document(dateStr).getDocument { (document, error) in
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
                    
                    let summary = data?["summary"] as? String ?? ""
                    if (summary == "") {
                        self.progressTextView.text = ""
                    } else {
                        self.progressTextView.text = summary
                    }
                    
                    let satisfy = data?["satisfy"] as? Int ?? 0
                    if (satisfy == 0) {
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
                    self.placeholderSetting(self.progressTextView)
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
    
    func CheckmarkButtonClicked(self : ToDoListViewController, checkTime : Bool, sender : UIButton) {
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
    
    func AddToDoListFactors(self : ToDoListViewController, checkTime : Bool) {
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
                                let name = document.data()["name"] as? String ?? ""
                                let email = document.data()["email"] as? String ?? ""
                                let subject = document.data()["subject"] as? String ?? ""
                                
                                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("ToDoList").addDocument(
                                    data: ["todo" : self.todoTF.text, "check" : checkTime]){ err in
                                        if let err = err {
                                            print("Error adding document: \(err)")
                                        } else {
                                            print("data is inserted!")
                                            
                                        }
                                    }
                                
                                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("ToDoList").whereField("todo", isEqualTo: self.todoTF.text).getDocuments() {
                                    (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            self.todoDoc.append(document.documentID)
                                            print("todoDoc: \(document.documentID)")
                                        }
                                    }
                                }
                                self.todoTF.text = ""
                            }
                        }
                    }
                }
        }
    }
    
    func GetScores(self : GraphViewController, studentEmail : String) {
        self.floatValue = [5,5]
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
                    // 그래프 정보 저장 경로
                    db.collection("student").document(studentUid).collection("Graph").document("Count").getDocument {(document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            let countOfScores = data?["count"] as? Int ?? 0
                            db.collection("student").document(studentUid).collection("Graph").whereField("isScore", isEqualTo: "true")
                                .getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        
                                        self.days = []
                                        self.scores = []
                                        
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
                                                        self.days.insert(document.data()["type"] as? String ?? "", at: i)
                                                        self.scores.insert(Double(document.data()["score"] as? String ?? "0.0")!, at: i)
                                                    }
                                                }
                                                setChart(dataPoints: self.days, values: self.scores, view: self.barChartView, design: self.chartDesign, colors: self.barColors, fvalue: self.floatValue)
                                            } else {
                                                self.barChartView.noDataText = "입력된 성적이 없어요! 입력해보는 건 어떨까요?"
                                                self.barChartView.noDataFont = .systemFont(ofSize: 14.0, weight: .bold)
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
            
        }
    }
    
    func GetUserInfoInDetailClassVC (self : MyClassDetailViewController?, detailClassVC: DetailClassViewController?, graphVC: GraphViewController?, todolistVC: ToDoListViewController?) {
        // 선생님이면
        
        guard let graphVC = graphVC else {
            return
        }
        guard let detailClassVC = detailClassVC else {
            return
        }
        guard let todolistVC = todolistVC else {
            return
        }
        guard let self = self else {
            return
        }
        
        db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    ///nil인지 확인
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    self.userType = "teacher"
                    detailClassVC.userType = "teacher"
                    graphVC.userType = "teacher"
                    todolistVC.userType = "teacher"
                    
                    for document in snapshot.documents { // 문서가 있다면
                        print("\(document.documentID) => \(document.data())")
                        // 선생님이므로 성적 추가하는 버튼은 보이지 않도록 superview에서 삭제
                        
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
                                                let email = document.data()["email"] as? String ?? ""
                                                let index = document.data()["index"] as? Int ?? 0
                                                let currentCnt = document.data()["currentCnt"] as? Int ?? 0
                                                
                                                self.currentCnt = currentCnt
                                                detailClassVC.currentCnt = self.currentCnt
                                                detailClassVC.payType = payType
                                                self.payType = payType
                                                
                                                let userEmail = document.data()["email"] as? String ?? ""
                                                
                                                let userSubject = document.data()["subject"] as? String ?? ""
                                                
                                                self.classNavigationBar.topItem!.title = name + " 학생"
                                                
                                                if index == linkBtnIndex {
                                                    self.userIndex = linkBtnIndex
                                                }
                                                
                                                detailClassVC.userIndex = self.userIndex
                                                graphVC.userIndex = self.userIndex
                                                todolistVC.userIndex = self.userIndex
                                                
                                                detailClassVC.userName = self.userName
                                                graphVC.userName = self.userName
                                                todolistVC.userName = self.userName
                                                
                                                detailClassVC.userEmail = self.userEmail
                                                graphVC.userEmail = self.userEmail
                                                todolistVC.userEmail = self.userEmail
                                                
                                                detailClassVC.userSubject = self.userSubject
                                                graphVC.userSubject = self.userSubject
                                                todolistVC.userSubject = self.userSubject
                                                
                                                self.studentEmail = email
                                                
                                                self.dataSourceVC.append(detailClassVC)
                                                self.dataSourceVC.append(graphVC)
                                                self.dataSourceVC.append(todolistVC)
                                                self.currentPage = 0
                                                
                                                todolistVC.todoDoc.removeAll()
                                                todolistVC.todos.removeAll()
                                                todolistVC.todoCheck.removeAll()
                                                
                                                // todolist도 가져오기
                                                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + userEmail + ") " + userSubject).collection("ToDoList").getDocuments {(snapshot, error) in
                                                    if let snapshot = snapshot {
                                                        
                                                        snapshot.documents.map { doc in
                                                            
                                                            if doc.data()["todo"] != nil{
                                                                // 순서대로 todolist를 담는 배열에 추가해주기
                                                                todolistVC.todoDoc.append(doc.documentID)
                                                                todolistVC.todos.append(doc.data()["todo"] as! String)
                                                                todolistVC.todoCheck.append(doc.data()["check"] as! Bool)
                                                            }
                                                        }
                                                    } else {
                                                        print("Document does not exist")
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
                    self.userType = "student"
                    detailClassVC.userType = "student"
                    graphVC.userType = "student"
                    todolistVC.userType = "student"
                    
                    for document in snapshot.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let studentName = document.data()["name"] as? String ?? ""
                        self.studentName = studentName
                        todolistVC.studentName = studentName
                        detailClassVC.studentName = studentName
                        graphVC.studentName = studentName
                        
                        let studentEmail = document.data()["email"] as? String ?? ""
                        todolistVC.studentEmail = studentEmail
                        detailClassVC.studentEmail = studentEmail
                        graphVC.studentEmail = studentEmail
                        
                        db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("email", isEqualTo: self.userEmail)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            let subject = document.data()["subject"] as? String ?? ""
                                            if (subject != self.userSubject) {
                                                continue
                                            }
                                            // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                            // 네비게이션 바의 이름도 설정해주기
                                            let name = document.data()["name"] as? String ?? ""
                                            let payType = document.data()["payType"] as? String ?? ""
                                            let index = document.data()["index"] as? Int ?? 0
                                            
                                            self.classNavigationBar.topItem!.title = name + " 선생님"
                                            
                                            detailClassVC.payType = payType
                                            
                                            let currentCnt = document.data()["currentCnt"] as? Int ?? 0
                                            detailClassVC.currentCnt = currentCnt
                                            
                                            detailClassVC.userName = name
                                            graphVC.userName = name
                                            self.userName = name
                                            todolistVC.userName = name
                                            
                                            let userEmail = document.data()["email"] as? String ?? ""
                                            detailClassVC.userEmail = userEmail
                                            graphVC.userEmail = userEmail
                                            self.userEmail = userEmail
                                            todolistVC.userEmail = userEmail
                                            
                                            let userSubject = document.data()["subject"] as? String ?? ""
                                            detailClassVC.userSubject = userSubject
                                            graphVC.userSubject = userSubject
                                            self.userSubject = userSubject
                                            todolistVC.userSubject = userSubject
                                            self.studentSubject = userSubject
                                            
                                            if index == linkBtnIndex {
                                                self.userIndex = linkBtnIndex
                                            }
                                            detailClassVC.userIndex = self.userIndex
                                            graphVC.userIndex = self.userIndex
                                            todolistVC.userIndex = self.userIndex
                                            
                                            detailClassVC.userName = self.userName
                                            graphVC.userName = self.userName
                                            todolistVC.userName = self.userName
                                            
                                            detailClassVC.userEmail = self.userEmail
                                            graphVC.userEmail = self.userEmail
                                            todolistVC.userEmail = self.userEmail
                                            
                                            detailClassVC.userSubject = self.userSubject
                                            graphVC.userSubject = self.userSubject
                                            todolistVC.userSubject = self.userSubject
                                            
                                            self.dataSourceVC.append(detailClassVC)
                                            self.dataSourceVC.append(graphVC)
                                            self.dataSourceVC.append(todolistVC)
                                            
                                            self.currentPage = 0
                                        }
                                    }
                                }
                            }
                        
                        if let email = self.userEmail { // 사용자의 이메일이 nil이 아니라면
                            // 선생님들 정보의 경로 중 이메일이 일치하는 선생님 찾기
                            db.collection("teacher").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let teacherUid = document.data()["uid"] as? String ?? ""
                                        let teacherName = document.data()["name"] as? String ?? ""
                                        
                                        todolistVC.teacherUid = teacherUid
                                        self.teacherUid = teacherUid
                                        detailClassVC.teacherUid = teacherUid
                                        
                                        todolistVC.todoDoc.removeAll()
                                        todolistVC.todos.removeAll()
                                        todolistVC.todoCheck.removeAll()
                                        
                                        if let index = self.userIndex { // userIndex가 nil이 아니라면
                                            // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                                            db.collection("teacher").document(teacherUid).collection("class").whereField("index", isEqualTo: index)
                                                .getDocuments() { (querySnapshot, err) in
                                                    if let err = err {
                                                        print(">>>>> document 에러 : \(err)")
                                                    } else {
                                                        if let err = err {
                                                            print("Error getting documents: \(err)")
                                                        } else {
                                                            for document in querySnapshot!.documents {
                                                                print("\(document.documentID) => \(document.data())")
                                                                
                                                                print ("===== \(teacherUid) / \(studentName) / \(studentEmail) / \(self.studentSubject)")
                                                                // 선생님의 수업 목록 중 학생과 일치하는 정보 불러오기
                                                                db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.userSubject).collection("ToDoList").getDocuments {(snapshot, error) in
                                                                    if let snapshot = snapshot {
                                                                        snapshot.documents.map { doc in
                                                                            if doc.data()["todo"] != nil{
                                                                                // 순서대로 todolist를 담는 배열에 추가해주기
                                                                                todolistVC.todoDoc.append(doc.documentID)
                                                                                todolistVC.todos.append(doc.data()["todo"] as! String)
                                                                                todolistVC.todoCheck.append(doc.data()["check"] as! Bool)
                                                                            }
                                                                        }
                                                                    } else {
                                                                        print("Document does not exist")
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
    
    func DeleteToDoList(self: ToDoListViewController, sender : UIButton) {
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
                                let name = document.data()["name"] as? String ?? ""
                                let email = document.data()["email"] as? String ?? ""
                                let subject = document.data()["subject"] as? String ?? ""
                                
                                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("ToDoList").document(self.todoDoc[sender.tag]).delete() { err in
                                    if let err = err {
                                        
                                        print("Error removing document: \(err)")
                                    } else {
                                        print("Document successfully removed!")
                                    }
                                }
                                self.todos.remove(at: sender.tag)
                                self.todoDoc.remove(at: sender.tag)
                                self.todoCheck.remove(at: sender.tag)
                                
                                self.todoTableView.reloadData()
                            }
                        }
                    }
                }
            
        }
    }
    
    func SaveGraphScore(todayStudy: String, todayScore : String, self : PlusGraphViewController) {
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
    func GetScoreForEdit(self : PlusGraphViewController, todayStudy: String) {
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
}
