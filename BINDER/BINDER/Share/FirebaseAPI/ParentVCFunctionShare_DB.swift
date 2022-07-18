//
//  ParentVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit
import FSCalendar

struct ParentDBFunctions {
    var functionShare = FunctionShare()
    
    func GetParentUserInfo(self : ParentHomeViewController) {
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    /// 문서 존재하면
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        print("\(document.documentID) => \(document.data())")
                        // 이름 받아서 학부모 이름 label의 text를 'OOO 학부모님'으로 지정
                        let name = data["name"] as? String ?? ""
                        self.parentNameLabel.text = name + " 학부모님!"
                    }
                }
            }
        }
    }
    
    func SetEvaluation(self : ParentHomeViewController) {
        self.teacherEmails.removeAll()
        self.teacherNames.removeAll()
        
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
                    let data = document.data()
                    let childPhoneNumber = data["childPhoneNumber"] as? String ?? ""
                    // student collection에서 가져온 휴대폰 번호와 같은 본인 휴대폰 번호 정보를 가지는 문서 찾기
                    db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let data = document.data()
                                let studentUid = data["uid"] as? String ?? "" // 학생 uid 정보
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
    
    func DeleteChildPhone() {
        /// parent/현재 유저의 uid에서 문서를 가져와서 문서가 있다면
        db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                /// parent의 childPhoneNumber 를 없애주기 (공백으로 갱신)
                db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                    "childPhoneNumber": ""
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func GetParentInfo(self : ParentMyPageViewController) {
        // parent collection에서 uid 필드가 현재 사용자의 uid와 동일한 문서 찾기
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
                        let data = document.data()
                        if LoadingHUD.isLoaded == false {
                            LoadingHUD.show()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                LoadingHUD.isLoaded = true
                                LoadingHUD.hide()
                            }
                        }
                        let profile = data["profile"] as? String ?? "https://i.postimg.cc/Z5hfxYqS/parent-profile.png" // 학부모 프로필 이미지 링크 가져오기
                        let name = data["name"] as? String ?? "" // 학부모 이름
                        let childPhoneNumber = data["childPhoneNumber"] as? String ?? "" // 자녀 휴대폰 번호
                        
                        if (childPhoneNumber == "") { /// 자녀 휴대폰 번호 공백이면
                            // 자녀 휴대폰 번호 backgroundview 안 보여도 됨
                            self.childInfoBackgroundView.isHidden = true
                        } else { /// 공백 아니면
                            // 자녀 휴대폰 번호 backgroundview 보이도록 설정
                            self.childInfoBackgroundView.isHidden = false
                        }
                        
                        var childPhoneNumberWithDash = "" // '-'가 들어간 번호로 다시 만들어 주기 위해 사용
                        if (childPhoneNumber.contains("-")) { /// '-'가 있는 휴대폰 번호의 경우
                            childPhoneNumberWithDash = childPhoneNumber // '-'가 들어간 번호 변수에 그대로 사용
                        } else {  /// '-'가 없는 휴대폰 번호의 경우
                            var firstPart = "" // 010 파트
                            var secondPart = "" // 중간 번호 파트
                            var thirdPart = "" // 끝 번호 파트
                            var count = 0 // 몇 개의 숫자를 셌는지 파악하기 위한 변수
                            
                            for char in childPhoneNumber{ // childPhoneNumber가 String이므로 하나하나의 문자를 사용
                                if (count >= 0 && count <= 2) { // 0-2번째에 해당하는 수는 010 파트로 저장
                                    firstPart += String(char)
                                } else if (count >= 3 && count <= 6){ // 3-6번째에 해당하는 수는 중간 번호 파트로 저장
                                    secondPart += String(char)
                                } else if (count >= 7 && count <= 10){ // 7-10번째에 해당하는 수는 끝 번호 파트로 저장
                                    thirdPart += String(char)
                                }
                                // 한 번 할 때마다 count 하나씩 증가
                                count = count + 1
                                
                            }
                            // '-'가 들어간 번호 변수에 010 파트와 중간 번호 하트, 끝 번호 파트를 '-'로 연결해서 저장
                            childPhoneNumberWithDash = firstPart + " - " + secondPart + " - " + thirdPart
                        }
                        
                        // student collection에서 학생의 휴대전화번호가 '-'가 들어간 번호 변수의 값과 같다면
                        db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumberWithDash).getDocuments { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                if let err = err {
                                    print("Error getting documents(inMyClassView): \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let data = document.data()
                                        let childName = data["name"] as? String ?? "" // 학생 (자녀) 이름
                                        self.childNameLabel.text = childName + " 학생" // 자녀 이름 label의 이름으로 사용
                                    }
                                }
                            }
                        }
                        self.childPhoneNumberLabel.text = childPhoneNumberWithDash // 학생 (자녀) 휴대전화 번호 text로 지정
                        self.nameLabel.text = name // 학부모 이름 label은 가져온 학부모의 이름으로 지정
                        let url = URL(string: profile)! // url은 가져온 학부모의 profile 링크를 URL로 변환해 저장
                        self.profileImageView.kf.setImage(with: url) // profileImageView의 image를 가져온 url을 사용해 설정
                        self.profileImageView.makeCircle() // 프로필 이미지를 원으로 보이도록 설정
                    }
                }
            }
        }
    }
    
    func SaveProfileImage(self : ParentMyPageViewController, profile : String) {
        let image = self.profileImageView.image!
        if let data = image.pngData(){
            let urlRef = storageRef.child("image/\(profile).png")
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
                    
                    db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                        "profile":"\(downloadURL)",
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                }
            }
        }
    }
    
    func GetChildrenInfo(self : ParentDetailEvaluationViewController) {
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
                    let data = document.data()
                    let childPhoneNumber = data["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
                    
                    /// student collection에서 위에서 가져온 childPhoneNumber와 동일한 휴대전화 번호 정보를 가지는 사람이 있는지 찾기
                    db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                functionShare.LoadingShow(sec: 1.0)
                                let data = document.data()
                                let studentName = data["name"] as? String ?? "" // 학생 이름
                                self.studentName = studentName // self.studentName에 저장
                                self.monthlyEvaluationTitle.text = "이번 달 " + studentName + " 학생은..." // 이번 달 평가 제목에 사용
                                let studentEmail = data["email"] as? String ?? "" // 학생 이메일
                                self.studentEmail = studentEmail
                            }
                        }
                    }
                }
            }
        }
    }
    
    func GetStudentMonthlyEvaluations(self : ParentDetailEvaluationViewController) {
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
                        if let month = self.month {
                            self.monthlyEvaluationTextView.text = "\(month)달 월말 평가가 등록되지 않았습니다."
                        }
                        
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let data = document.data()
                            let studentUid = data["uid"] as? String ?? "" // 학생 uid
                            
                            /// student collection / studentUid / class collection에서 index필드의 값이 self.index와 동일한 문서를 찾기
                            db.collection("student").document(studentUid).collection("class").whereField("index", isEqualTo: self.index).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let data = document.data()
                                        let name = data["name"] as? String ?? "" // 선생님 이름
                                        self.teacherName = name // 선생님 이름으로 설정
                                        let email = data["email"] as? String ?? "" // 선생님 이메일
                                        self.teacherEmail = email // 선생님 이메일로 설정
                                        let subject = data["subject"] as? String ?? "" // 과목
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
    
    func GetStudentDailyEvaluations (self : ParentDetailEvaluationViewController) {
        // 데이터베이스 경로
        let formatter = DateFormatter()
        self.events.removeAll()
        
        db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let teacherUid = data["uid"] as? String ?? "" // 선생님 uid
                    
                    db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let data = document.data()
                                let childPhoneNumber = data["childPhoneNumber"] as? String ?? ""
                                
                                db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            let data = document.data()
                                            let studentEmail = data["email"] as? String ?? "" // 학생 이메일
                                            
                                            db.collection("teacher").document(teacherUid).collection("class").whereField("email", isEqualTo: self.studentEmail).getDocuments() { (querySnapshot, err) in
                                                if let err = err {
                                                    print(">>>>> document 에러 : \(err)")
                                                } else {
                                                    for document in querySnapshot!.documents {
                                                        print("\(document.documentID) => \(document.data())")
                                                        let data = document.data()
                                                        let subject = data["subject"] as? String ?? ""
                                                        
                                                        if subject != self.subject {
                                                            continue
                                                        }
                                                        
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
                                                                        let data = document.data()
                                                                        // 사용할 것들 가져와서 지역 변수로 저장
                                                                        let date = data["evaluationDate"] as? String ?? ""
                                                                        
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
            self.calendarView.reloadData()
        }
    }
    
    func GetUserAndClassInfo(self : TeacherEvaluationViewController) {
        /// parent collection / 현재 사용자 uid 경로에서 문서 찾기
        db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists { /// 문서 있으면
                let data = document.data()
                let childPhoneNumber = data!["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
                ///  student collection에 가져온 학생 전화번호와 동일한 전화번호 정보를 가지는 문서 찾기
                db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        /// 문서 있으면
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let studentName = document.data()["name"] as? String ?? "" // 학생 이름
                            self.studentName = studentName
                            
                            db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                                        
                                        /// parent collection / 현재 사용자 uid / teacherEvaluation collection / 선생님이름(선생님이메일) 과목 / evaluation 경로에서 문서 찾기
                                        db.collection("teacherEvaluation").document(teacherUid).collection("evaluation").document(studentName + " " + self.month).getDocument { (document, error) in
                                            if let document = document, document.exists {
                                                let data = document.data()
                                                let teacherAttitude = data!["teacherAttitude"] as? String ?? "" // 선생님 태도 점수
                                                let teacherManagingSatisfyScore = data!["teacherManagingSatisfyScore"] as? String ?? "" // 학생 관리 만족도 점수
                                                self.teacherAttitude.text = teacherAttitude // 선생님 태도 점수 text 지정
                                                self.teacherManagingSatisfyScore.text = teacherManagingSatisfyScore // 학생 관리 만족도 점수 지정
                                            }
                                        }
                                    }
                                }
                            }
                            
                            self.studentTitle.text = studentName + " 학생의 " + self.date + " 수업은..." // 학생 평가 title text 설정
                            self.evaluationTextView.isEditable = false // 평가 textview 수정 못하도록 설정
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func GetEvaluation (self : TeacherEvaluationViewController) {
        // 데이터베이스 경로
        db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                    self.teacherUid = teacherUid
                    let parentDocRef = db.collection("parent")
                    parentDocRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
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
                                            let studentName = document.data()["name"] as? String ?? "" // 학생 이메일
                                            
                                            db.collection("teacher").document(teacherUid).collection("class").whereField("email", isEqualTo: studentEmail).getDocuments() { (querySnapshot, err) in
                                                if let err = err {
                                                    print(">>>>> document 에러 : \(err)")
                                                } else {
                                                    for document in querySnapshot!.documents {
                                                        print("\(document.documentID) => \(document.data())")
                                                        let subject = document.data()["subject"] as? String ?? ""
                                                        
                                                        db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + subject).collection("Evaluation").whereField("evaluationDate", isEqualTo: self.date).getDocuments() { (querySnapshot, err) in
                                                            if let err = err {
                                                                print("Error getting documents: \(err)")
                                                            } else {
                                                                for document in querySnapshot!.documents {
                                                                    print("\(document.documentID) => \(document.data())")
                                                                    // 사용할 것들 가져와서 지역 변수로 저장
                                                                    let evaluationMemo = document.data()["evaluationMemo"] as? String ?? "선택된 날짜에는 수업이 없었습니다."
                                                                    let homeworkCompletion = document.data()["homeworkCompletion"] as? Int ?? 0
                                                                    self.averageHomeworkCompletion.text = "\(homeworkCompletion) 점"
                                                                    let classAttitude = document.data()["classAttitude"] as? Int ?? 0
                                                                    self.averageClassAttitude.text = "\(classAttitude) 점"
                                                                    let testScore = document.data()["testScore"] as? Int ?? 0
                                                                    self.averageTestScore.text = "\(testScore) 점"
                                                                    self.evaluationTextView.text = evaluationMemo
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
    
    func SaveTeacherEvaluation(self : TeacherEvaluationViewController) {
        /// parent collection / 현재 사용자 Uid / teacherEvaluation / 선생님이름(선생님이메일) / 현재 달 collection / evaluation 아래에 선생님 태도 점수와 학생 관리 만족도 점수 저장
        db.collection("teacherEvaluation").document(self.teacherUid).collection("evaluation").document(self.studentName + " " + self.month)
            .setData([
                "teacherUid": self.teacherUid,
                "teacherAttitude": self.teacherAttitude.text!,
                "teacherManagingSatisfyScore": self.teacherManagingSatisfyScore.text!
            ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func GetParentInfoForParentDetailVC(self : ParentDetailEvaluationViewController) {
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
                        self.monthlyEvaluationTextView.text = "\(self.month!)달 월말 평가가 등록되지 않았습니다."
                        
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
}
