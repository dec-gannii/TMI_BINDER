//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

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

public func GetUserInfoForMyPage(self : MyPageViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            LoginRepository.shared.doLogin {
                self.nameLabel.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
                self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
                self.type = "teacher"
                let url = URL(string: LoginRepository.shared.teacherItem!.profile)!
                self.imageView.kf.setImage(with: url)
                self.imageView.makeCircle()
            } failure: { error in
                self.showDefaultAlert(msg: "")
            }
        } else {
            db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let userName = data?["name"] as? String ?? ""
                    self.nameLabel.text = "\(userName) 학생"
                    let userEmail = data?["email"] as? String ?? ""
                    self.teacherEmail.text = userEmail
                    let profile =  data?["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                    let goal = data?["goal"] as? String ?? "목표를 작성하지 않았습니다."
                    self.type = "student"
                    let url = URL(string: profile)!
                    self.imageView.kf.setImage(with: url)
                    self.imageView.makeCircle()
                    self.viewDecorating()
                    self.openPortfolioSwitch.removeFromSuperview()
                    self.portfoiolBtn.removeFromSuperview()
                    self.pageViewTitleLabel.text = "목표"
                    self.pageViewContentLabel.text = goal
                    self.pageViewContentLabel.numberOfLines = 2
                    
                    self.pageViewContentLabel.rightAnchor.constraint(equalTo: self.pageView.rightAnchor
                                , constant: -20).isActive = true
                    self.pageViewTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
                    self.pageViewTitleLabel.topAnchor.constraint(equalTo: self.pageView.topAnchor
                                , constant: 20).isActive = true
                    self.pageView.heightAnchor.constraint(equalToConstant: 120)
                                .isActive = true
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

public func GetPortfolioShow(self : MyPageViewController) {
    let db = Firestore.firestore()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            
            let isShowOK = data?["portfolioShow"] as? String ?? ""
            if (isShowOK == "On") {
                self.openPortfolioSwitch.setOn(true, animated: true)
            } else {
                self.openPortfolioSwitch.setOn(false, animated: true)
            }
            
            print("Document data: \(dataDescription)")
        } else {
            print("Document does not exist")
        }
    }
}

public func PortfolioToggleButtonClicked(self : MyPageViewController) {
    let db = Firestore.firestore()
    
    if (self.openPortfolioSwitch.isOn) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
            "portfolioShow": "On"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    } else {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
            "portfolioShow": "Off"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
}

public func SaveImage(self : MyPageViewController) {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var storageRef = storage.reference()
    
    let image = self.imageView.image!
    if let data = image.pngData(){
        let urlRef = storageRef.child("image/\(self.profile!).png")
        
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
                
                self.db.collection(self.type).document(Auth.auth().currentUser!.uid).updateData([
                    "profile":"\(downloadURL)",
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                if (self.type == "teacher") {
                    LoginRepository.shared.teacherItem?.profile = "\(downloadURL)"
                } else if (self.type == "student") {
                    LoginRepository.shared.studentItem?.profile = "\(downloadURL)"
                }
            }
        }
    }
}
