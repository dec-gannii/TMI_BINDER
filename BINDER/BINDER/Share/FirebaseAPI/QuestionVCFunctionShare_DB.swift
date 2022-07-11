//
//  QuestionVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/11.
//

import Foundation
import Firebase
import FirebaseFirestore
import AuthenticationServices
import FirebaseStorage
import UIKit
import AVKit

struct QuestionDBFunctions {
    var functionShare = FunctionShare()
    
    func UpdateImage(self : QuestionPlusViewController) {
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
                            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
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
                                                
                                                db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
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
    
    func SetQuestionDoc(self : QuestionPlusViewController) {
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
                                            guard let image = self.imageView.image else {
                                                db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").document(String(self.qnum)).setData([
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
                                                let urlRef = storageRef.child("image/\(self.file_name!).png")
                                                let metadata = StorageMetadata()
                                                metadata.contentType = "image/png"
                                                let uploadTask = urlRef.putData(data, metadata: metadata){ (metadata, error) in
                                                    guard let metadata = metadata else {
                                                        return}
                                                    urlRef.downloadURL { (url, error) in
                                                        guard let downloadURL = url else {
                                                            return}
                                                        
                                                        db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").document(String(self.qnum)).setData([
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
                    functionShare.LoadingShow(sec: 1.3)
                    if let preVC = self.presentingViewController as? UIViewController {
                        preVC.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func UpdateAnswer(answer : String, imgtype : Int, self : AnswerViewController, imgView : UIImageView) {
        if answer == "내용이 잘 이해가 가지 않거나 모르겠는 내용을 질문해보세요." || answer == "" {
            functionShare.AlertShow(alertTitle: "내용 없음", message: "질문이 있는 교재의 페이지 또는 질문 내용을 작성해주세요.", okTitle: "확인", self: self)
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
                    let urlRef = storageRef.child("image/\(self.newImage).png")
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
                            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").document(String(self.qnum)).collection("answer").document(Auth.auth().currentUser!.uid).setData([
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
    
    func GetUserInfoInQuestionView(toggleLabel : UILabel, index : Int, navigationBar : UINavigationBar, navigationBarItem : UINavigationItem, self : QuestionListViewController) {
        
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
    
    func SetQuestionList(self : QuestionListViewController) {
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
    
    func GetUserInfoInQuestionVC (self : QuestionViewController) {
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
                        self.setStudentInfo()
                    }
                }
            }
        }
    }
    
    func SetQuestionRoom (self : QuestionViewController) {
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
    
    func QuestionCellClicked(self : QuestionViewController, indexPath : IndexPath) {
        let docRef : CollectionReference!
        
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
    
    func GetUserInfoInQuestionDetailVC (self : QuestionDetailViewController) {
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
                            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
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
                                                
                                                db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
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
    
    func SetQuestion(self : QuestionDetailViewController) {
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
                            
                            let size = CGSize(width: self.view.frame.width, height: .infinity)
                            let estimatedSize = self.questionContent.sizeThatFits(size)
                            
                            self.questionContent.constraints.forEach { (constraint) in
                                
                                /// 180 이하일때는 더 이상 줄어들지 않게하기
                                if estimatedSize.height <= 180 {
                                    
                                }
                                else {
                                    if constraint.firstAttribute == .height {
                                        constraint.constant = estimatedSize.height
                                    }
                                }
                            }
                            
                            self.questionContent.text = questionContent
                            if imgURL != "" {
                                self.imgView.isHidden = false
                                let url = URL(string: imgURL)
                                DispatchQueue.global().async {
                                    let data = try? Data(contentsOf: url!)
                                    DispatchQueue.main.async {
                                        self.imgView.image = UIImage(data: data!)
                                    }
                                }
                            } else if (imgURL == "") {
                                self.imgView.isHidden = true
                            }
                            self.questionContent.translatesAutoresizingMaskIntoConstraints = true
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
                                                            
                                                            let size = CGSize(width: self.view.frame.width, height: .infinity)
                                                            let estimatedSize = self.questionContent.sizeThatFits(size)
                                                            
                                                            self.questionContent.constraints.forEach { (constraint) in
                                                                
                                                                /// 180 이하일때는 더 이상 줄어들지 않게하기
                                                                if estimatedSize.height <= 180 {
                                                                    
                                                                }
                                                                else {
                                                                    if constraint.firstAttribute == .height {
                                                                        constraint.constant = estimatedSize.height
                                                                    }
                                                                }
                                                            }
                                                            
                                                            self.questionContent.text = questionContent
                                                            if imgURL != "" {
                                                                self.imgView.isHidden = false
                                                                let url = URL(string: imgURL)
                                                                DispatchQueue.global().async {
                                                                    let data = try? Data(contentsOf: url!)
                                                                    DispatchQueue.main.async {
                                                                        self.imgView.image = UIImage(data: data!)
                                                                    }
                                                                }
                                                            } else if (imgURL == "") {
                                                                self.imgView.isHidden = true
                                                            }
                                                            
                                                            self.questionContent.translatesAutoresizingMaskIntoConstraints = true
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
    
    func GetUserInfoInQnADetailVC (self : QnADetailViewController) {
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
                            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
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
                                                
                                                db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
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
    
    func SetQnA (self : QnADetailViewController) {
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
                            
                            var answer = questionDt["answerContent"] as? String ?? ""
                            if (answer == "답변 내용을 작성해주세요.") {
                                answer = ""
                            }
                            let imgurl = questionDt["url"] as? String ?? ""
                            let imgType = questionDt["type"] as? String ?? ""
                            
                            self.answerContent.text = answer
                            self.answerContent.translatesAutoresizingMaskIntoConstraints = true
                            let size = CGSize(width: self.answerView.frame.width, height: .infinity)
                            let estimatedSize = self.answerContent.sizeThatFits(size)
                            
                            self.answerContent.constraints.forEach { (constraint) in
                                
                                /// 180 이하일때는 더 이상 줄어들지 않게하기
                                if estimatedSize.height <= 180 {
                                    
                                }
                                else {
                                    if constraint.firstAttribute == .height {
                                        constraint.constant = estimatedSize.height
                                    }
                                }
                            }
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
                                    DispatchQueue.main.async {
                                        self.player = AVPlayer(url: url!)
                                        self.avPlayerLayer = {
                                            let layer = AVPlayerLayer(player: self.player)
                                            layer.videoGravity = .resizeAspect
                                            layer.needsDisplayOnBoundsChange = true
                                            return layer
                                        }()
                                        self.videourl = url
                                        self.answerImgView.layer.addSublayer(self.avPlayerLayer)
                                    }
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
                            self.questionContent.isScrollEnabled = false
                            
                            if imgURL != "" {
                                let url = URL(string: imgURL)
                                DispatchQueue.global().async {
                                    let data = try? Data(contentsOf: url!)
                                    DispatchQueue.main.async {
                                        self.questionImgView.image = UIImage(data: data!)
                                        self.questionView.heightAnchor.constraint(equalToConstant: self.view.frame.height + self.questionImgView.frame.height + 50)
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
            functionShare.LoadingShow(sec: 1.0)
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
                                                            self.questionContent.isScrollEnabled = false
                                                            
                                                            if imgURL != "" {
                                                                let url = URL(string: imgURL)
                                                                DispatchQueue.global().async {
                                                                    let data = try? Data(contentsOf: url!)
                                                                    DispatchQueue.main.async {
                                                                        self.questionImgView.image = UIImage(data: data!)
                                                                        self.questionView.heightAnchor.constraint(equalToConstant: self.view.frame.height + self.questionImgView.frame.height + 50)
                                                                            .isActive = true
                                                                        
                                                                    }
                                                                }
                                                            } else if (imgURL == "") {
                                                                self.answerImgView.isHidden = true
                                                                self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + 50)
                                                                    .isActive = true
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            //답변 내용
                                            db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").document(String(self.qnum!)).collection("answer").whereField("isAnswer", isEqualTo: true).getDocuments() { (querySnapshot, err) in
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
                                                        let size = CGSize(width: self.answerView.frame.width, height: .infinity)
                                                        let estimatedSize = self.answerContent.sizeThatFits(size)
                                                        
                                                        self.answerContent.constraints.forEach { (constraint) in
                                                            
                                                            /// 180 이하일때는 더 이상 줄어들지 않게하기
                                                            if estimatedSize.height <= 180 {
                                                                
                                                            }
                                                            else {
                                                                if constraint.firstAttribute == .height {
                                                                    constraint.constant = estimatedSize.height
                                                                }
                                                            }
                                                        }
                                                        self.answerContent.isScrollEnabled = false
                                                        
                                                        if (imgurl == "" || imgurl == "nil") {
                                                            if (self.answerImgView != nil) {
                                                                self.answerImgView.image = .none
                                                                self.answerImgView.isHidden = true
                                                                self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + 50)
                                                                    .isActive = true
                                                            }
                                                        } else {
                                                            if imgType == "image"{
                                                                let url = URL(string: imgurl)
                                                                self.answerImgView.isHidden = false
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
                                                                self.answerImgView.isHidden = true
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
}
