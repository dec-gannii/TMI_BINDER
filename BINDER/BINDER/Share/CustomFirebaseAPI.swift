//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore
import AVKit
import Kingfisher

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
