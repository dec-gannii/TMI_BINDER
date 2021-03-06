//
//  DetailClassVCFunctionShare_DB.swift
//  BINDER
//
//  Created by κΉκ°μ on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit
import FSCalendar

struct DetailClassDBFunctions {
    let notification = PushNotificationSender()
    
    func SaveMonthlyEvaluation(self : DetailClassViewController) {
        let date = self.selectedMonth + "μ"
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
                            notification.sendPushNotification(token: self.fcmToken, title: "μκΈ κΈ°κ°μ΄μμ!", body: "\(self.tname!) μ μλκ» κ΅μ‘λΉλ₯Ό μκΈν΄μ£ΌμΈμ.")
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
                                let studentUid = document.data()["uid"] as? String ?? "" // νμμ uid λ³μμ μ μ₯
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
        // κ²½λ‘λ κ° νμμ classμ Evaluation
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
                // μ μ₯ μ΄νμλ λ€μ μ λ³΄μ΄λλ‘ ν¨
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
                    let subject = data?["subject"] as? String ?? "" // κ³Όλͺ©
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
                            let name =  data?["name"] as? String ?? "" // μ μλ μ΄λ¦
                            let email = data?["email"] as? String ?? "" // μ μλ μ΄λ©μΌ
                            
                            db.collection("student").whereField("email", isEqualTo: self.userEmail!).getDocuments() { (querySnapshot, err) in
                                if let err = err { // νμ μ΄λ©μΌμ΄λ κ°μΌλ©΄
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        // μ¬μ©ν  κ²λ€ κ°μ Έμμ μ§μ­ λ³μλ‘ μ μ₯
                                        let uid = document.data()["uid"] as? String ?? "" // νμ uid
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
                    print("λ²νΌ ν΄λ¦­ ν Document does not exist")
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
                // μ μ₯ μ΄νμλ λ€μ μ λ³΄μ΄λλ‘ ν¨
                self.evaluationOKBtn.isHidden = true
                self.evaluationView.isHidden = true
                
                self.progressTextView.text = ""
                self.testScoreTextField.text = ""
                self.evaluationMemoTextView.text = ""
            }
        }
    }
    
    func GetEvaluations(self : DetailClassViewController, dateStr : String) {
        // λ°μ΄ν°λ² μ΄μ€ κ²½λ‘
        if (self.userType == "teacher") {
            // λ°μ΄ν°λ₯Ό λ°μμμ κ°κ°μ κ°μ λ°λΌ textfield κ° μ€μ  (λ§μ½ μλ€λ©΄ κ³΅λ°± μ€μ , μλ€λ©΄ κ·Έ κ° λΆλ¬μ΄)
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
                    // κ° λ€μ κ³΅λ°± μ€μ 
                    self.resetTextFields()
                }
            }
            
            db.collection("student").whereField("email", isEqualTo: self.userEmail!).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents { // λ¬Έμκ° μλ€λ©΄
                        print("\(document.documentID) => \(document.data())")
                        let studentUid = document.data()["uid"] as? String ?? ""
                        
                        db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents { // λ¬Έμκ° μλ€λ©΄
                                    print("\(document.documentID) => \(document.data())")
                                    let teacherName = document.data()["name"] as? String ?? ""
                                    let teacherEmail = document.data()["email"] as? String ?? ""
                                    if let selectedMonth = self.selectedMonth {
                                        db.collection("student").document(studentUid).collection("class").document(teacherName + "(" + teacherEmail + ") " + self.userSubject).collection("Evaluation").document(selectedMonth + "μ").getDocument(){ (document, error) in
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
            // λ°μ΄ν°λ₯Ό λ°μμμ κ°κ°μ κ°μ λ°λΌ textfield κ° μ€μ  (λ§μ½ μλ€λ©΄ κ³΅λ°± μ€μ , μλ€λ©΄ κ·Έ κ° λΆλ¬μ΄)
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
            // κ·Έλλ‘ μ¨κΉ μ μ§
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
        if let index = self.userIndex { // userIndexκ° nilμ΄ μλλΌλ©΄
            // indexκ° νμ¬ κ΄λ¦¬νλ νμμ μΈλ±μ€μ λμΌνμ§ λΉκ΅ ν κ°μ νμμ λ°μ΄ν° κ°μ Έμ€κΈ°
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document μλ¬ : \(err)")
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
                                        print(">>>>> document μλ¬ : \(err)")
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
        // νμμ μ λ³΄λ€ μ€ μ΄λ©μΌμ΄ λμΌν μ λ³΄ λΆλ¬μ€κΈ°
        var studentUid = ""
        db.collection("student").whereField("email", isEqualTo: studentEmail).getDocuments() {
            (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    studentUid = document.data()["uid"] as? String ?? "" // νμμ uid λ³μμ μ μ₯
                    // κ·Έλν μ λ³΄ μ μ₯ κ²½λ‘
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
                                                self.barChartView.noDataText = "μλ ₯λ μ±μ μ΄ μμ΄μ! μλ ₯ν΄λ³΄λ κ±΄ μ΄λ¨κΉμ?"
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
        // μ μλμ΄λ©΄
        
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
        
        db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid νλκ° νμ¬ λ‘κ·ΈμΈν μ¬μ©μμ Uidμ κ°μ νλ μ°ΎκΈ°
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    ///nilμΈμ§ νμΈ
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    self.userType = "teacher"
                    detailClassVC.userType = "teacher"
                    graphVC.userType = "teacher"
                    todolistVC.userType = "teacher"
                    
                    for document in snapshot.documents { // λ¬Έμκ° μλ€λ©΄
                        print("\(document.documentID) => \(document.data())")
                        // μ μλμ΄λ―λ‘ μ±μ  μΆκ°νλ λ²νΌμ λ³΄μ΄μ§ μλλ‘ superviewμμ μ­μ 
                        
                        if let index = self.userIndex { // userIndexκ° nilμ΄ μλλΌλ©΄
                            // indexκ° νμ¬ κ΄λ¦¬νλ νμμ μΈλ±μ€μ λμΌνμ§ λΉκ΅ ν κ°μ νμμ λ°μ΄ν° κ°μ Έμ€κΈ°
                            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                                .getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document μλ¬ : \(err)")
                                    } else {
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                        } else {
                                            for document in querySnapshot!.documents {
                                                print("\(document.documentID) => \(document.data())")
                                                // μ΄λ¦κ³Ό μ΄λ©μΌ, κ³Όλͺ© λ±μ κ°μ Έμμ κ°κ°μ μ μ₯ν  λ³μμ μ μ₯
                                                // λ€λΉκ²μ΄μ λ°μ μ΄λ¦λ μ€μ ν΄μ£ΌκΈ°
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
                                                
                                                self.classNavigationBar.topItem!.title = name + " νμ"
                                                
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
                                                
                                                // todolistλ κ°μ Έμ€κΈ°
                                                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + userEmail + ") " + userSubject).collection("ToDoList").getDocuments {(snapshot, error) in
                                                    if let snapshot = snapshot {
                                                        
                                                        snapshot.documents.map { doc in
                                                            
                                                            if doc.data()["todo"] != nil{
                                                                // μμλλ‘ todolistλ₯Ό λ΄λ λ°°μ΄μ μΆκ°ν΄μ£ΌκΈ°
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
        
        // νμμ΄λ©΄
        // Uid νλκ° νμ¬ λ‘κ·ΈμΈν μ¬μ©μμ Uidμ κ°μ νλ μ°ΎκΈ°
        db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    ///nilμΈμ§ νμΈ
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
                                    print(">>>>> document μλ¬ : \(err)")
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
                                            // μ΄λ¦κ³Ό μ΄λ©μΌ, κ³Όλͺ© λ±μ κ°μ Έμμ κ°κ°μ μ μ₯ν  λ³μμ μ μ₯
                                            // λ€λΉκ²μ΄μ λ°μ μ΄λ¦λ μ€μ ν΄μ£ΌκΈ°
                                            let name = document.data()["name"] as? String ?? ""
                                            let payType = document.data()["payType"] as? String ?? ""
                                            let index = document.data()["index"] as? Int ?? 0
                                            
                                            self.classNavigationBar.topItem!.title = name + " μ μλ"
                                            
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
                        
                        if let email = self.userEmail { // μ¬μ©μμ μ΄λ©μΌμ΄ nilμ΄ μλλΌλ©΄
                            // μ μλλ€ μ λ³΄μ κ²½λ‘ μ€ μ΄λ©μΌμ΄ μΌμΉνλ μ μλ μ°ΎκΈ°
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
                                        
                                        if let index = self.userIndex { // userIndexκ° nilμ΄ μλλΌλ©΄
                                            // indexκ° νμ¬ κ΄λ¦¬νλ νμμ μΈλ±μ€μ λμΌνμ§ λΉκ΅ ν κ°μ νμμ λ°μ΄ν° κ°μ Έμ€κΈ°
                                            db.collection("teacher").document(teacherUid).collection("class").whereField("index", isEqualTo: index)
                                                .getDocuments() { (querySnapshot, err) in
                                                    if let err = err {
                                                        print(">>>>> document μλ¬ : \(err)")
                                                    } else {
                                                        if let err = err {
                                                            print("Error getting documents: \(err)")
                                                        } else {
                                                            for document in querySnapshot!.documents {
                                                                print("\(document.documentID) => \(document.data())")
                                                                
                                                                print ("===== \(teacherUid) / \(studentName) / \(studentEmail) / \(self.studentSubject)")
                                                                // μ μλμ μμ λͺ©λ‘ μ€ νμκ³Ό μΌμΉνλ μ λ³΄ λΆλ¬μ€κΈ°
                                                                db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.userSubject).collection("ToDoList").getDocuments {(snapshot, error) in
                                                                    if let snapshot = snapshot {
                                                                        snapshot.documents.map { doc in
                                                                            if doc.data()["todo"] != nil{
                                                                                // μμλλ‘ todolistλ₯Ό λ΄λ λ°°μ΄μ μΆκ°ν΄μ£ΌκΈ°
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
        if let index = self.userIndex { // userIndexκ° nilμ΄ μλλΌλ©΄
            // indexκ° νμ¬ κ΄λ¦¬νλ νμμ μΈλ±μ€μ λμΌνμ§ λΉκ΅ ν κ°μ νμμ λ°μ΄ν° κ°μ Έμ€κΈ°
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document μλ¬ : \(err)")
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
        // λ°μ΄ν° μ μ₯
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
                
                // νμ¬ μ‘΄μ¬νλ λ°μ΄ν°κ° νλλ©΄,
                if (count == 1) {
                    // 1μΌλ‘ μ μ₯
                    db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph").document("Count").setData(["count": count])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                } else {
                    // νμ¬ μ‘΄μ¬νλ λ°μ΄ν°λ€μ΄ μ¬λ¬ κ°λ©΄, Count λνλ¨ΌνΈλ₯Ό ν¬ν¨ν κ²μ΄λ―λ‘
                    // νλλ₯Ό λΊ μλ‘ μ§μ ν΄μ μ μ₯ν΄μ€
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
                    print(">>>>> document μλ¬ : \(err)")
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
