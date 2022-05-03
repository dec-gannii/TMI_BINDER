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
