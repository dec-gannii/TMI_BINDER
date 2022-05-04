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

public func ShowPortfolio(self : ShowPortfolioViewController) {
    let db = Firestore.firestore()
    // 입력된 이메일과 동일한 값을 가지는 이메일 필드가 있다면 수행
    db.collection("teacher").whereField("email", isEqualTo: self.teacherEmailTextField.text!).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            // 도큐먼트 존재 안 하면 유효하지 않은 선생님 이메일이라고 alert 발생
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                let alert = UIAlertController(title: "탐색 오류", message: StringUtils.tEmailNotExist.rawValue, preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
                alert.addAction(okAction)
                self.present(alert, animated: false, completion: nil)
                return
            }
            
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                self.view.endEditing(true)
                let email = document.data()["email"] as? String ?? ""
                // 포트폴리오를 보여주는 화면 present
                guard let portfolioVC = self.storyboard?.instantiateViewController(withIdentifier: "PortfolioTableViewController") as? PortfolioTableViewController else { return }
                portfolioVC.isShowMode = true
                portfolioVC.showModeEmail = email
                self.present(portfolioVC, animated: true, completion: nil)
            }
        }
    }
    /// 변수 다시 공백으로 바꾸기
    self.teacherEmailTextField.text = ""
}

public func GetUserInfoInPortfolioTableViewController(self : PortfolioTableViewController) {
    let db = Firestore.firestore()
    
    self.teacherAttitudeArray.removeAll()
    self.teacherManagingSatisfyScoreArray.removeAll()
    
    if (self.isShowMode == true) { /// 포트폴리오 조회인 경우
        self.editBtn.isHidden = true // 수정 버튼 숨기기
        self.db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.teacherName.text = document.data()["name"] as? String ?? ""
                    self.teacherEmail.text = document.data()["email"] as? String ?? ""
                    let profile = document.data()["profile"] as? String ?? ""
                    let uid = document.data()["uid"] as? String ?? ""
                    self.teacherUid = uid
                    
                    self.db.collection("teacherEvaluation").document(uid).collection("evaluation").whereField("teacherUid", isEqualTo: uid).getDocuments() {
                        (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let teacherAttitude = document.data()["teacherAttitude"] as? String ?? ""
                                self.teacherAttitudeArray.append(Int(teacherAttitude)!)
                                let teacherManagingSatisfyScore = document.data()["teacherManagingSatisfyScore"] as? String ?? ""
                                self.teacherManagingSatisfyScoreArray.append(Int(teacherManagingSatisfyScore)!)
                            }
                        }
                    }
                    
                    self.infos.removeAll() // 원래 있는 제목 정보들 모두 지우기
                    
                    self.db.collection("teacher").document(uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            
                            let eduText = data?["eduHistory"] as? String ?? "" // 학력 정보
                            let classText = data?["classMethod"] as? String ?? "" // 수업 방식
                            let extraText = data?["extraExprience"] as? String ?? "" // 과외 경력
                            let time = data?["time"] as? String ?? "" // 과외 시간
                            let contact = data?["contact"] as? String ?? "" // 연락 수단
                            let manage = data?["manage"] as? String ?? "" // 학생 관리 방법
                            
                            if (eduText != "") {
                                self.infos.append("학력사항")
                            }
                            if (classText != "") {
                                self.infos.append("수업 방식")
                            }
                            if (extraText != "") {
                                self.infos.append("과외 경력")
                            }
                            if (time != "") {
                                self.infos.append("과외 시간")
                            }
                            if (contact != "") {
                                self.infos.append("연락 수단")
                            }
                            if (manage != "") {
                                self.infos.append("학생 관리 방법")
                            }
                            self.infos.append("선생님 평가")
                        }
                    }
                    self.teacherImage.kf.setImage(with: URL(string: profile)!)
                    self.teacherImage.makeCircle()
                }
            }
        }
    } else {
        self.infos.removeAll()
        self.teacherAttitudeArray.removeAll()
        self.teacherManagingSatisfyScoreArray.removeAll()

        self.db.collection("teacherEvaluation").document(Auth.auth().currentUser!.uid).collection("evaluation").whereField("teacherUid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let teacherAttitude = document.data()["teacherAttitude"] as? String ?? ""
                    self.teacherAttitudeArray.append(Int(teacherAttitude)!)
                    let teacherManagingSatisfyScore = document.data()["teacherManagingSatisfyScore"] as? String ?? ""
                    self.teacherManagingSatisfyScoreArray.append(Int(teacherManagingSatisfyScore)!)
                }
            }
        }

        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let eduText = data?["eduHistory"] as? String ?? ""
                let classText = data?["classMethod"] as? String ?? ""
                let extraText = data?["extraExprience"] as? String ?? ""
                let time = data?["time"] as? String ?? ""
                let contact = data?["contact"] as? String ?? ""
                let manage = data?["manage"] as? String ?? ""
                
                if (eduText != "") {
                    self.infos.append("학력사항")
                }
                if (classText != "") {
                    self.infos.append("수업 방식")
                }
                if (extraText != "") {
                    self.infos.append("과외 경력")
                }
                if (time != "") {
                    self.infos.append("과외 시간")
                }
                if (contact != "") {
                    self.infos.append("연락 수단")
                }
                if (manage != "") {
                    self.infos.append("학생 관리 방법")
                }
                self.infos.append("선생님 평가")
            }
        }
        
        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let name = data?["name"] as? String ?? ""
                self.teacherName.text = name
                let email = data?["email"] as? String ?? ""
                self.teacherEmail.text = email
                let profile = document.data()!["profile"] as? String ?? ""
                self.teacherImage.kf.setImage(with: URL(string: profile)!)
                self.teacherImage.makeCircle()
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
}

public func GetPortfolioFactors(self : PortfolioTableViewController, indexPath : IndexPath, cell : PortfolioDefaultCell) {
    let db = Firestore.firestore()
    
    if Auth.auth().currentUser?.uid != nil { // 현재 사용자의 uid가 nil이 아니면
        self.teacherUid = Auth.auth().currentUser!.uid // self.teacherUid 를 설정
    }
    
    var teacherAttitudeScoreAvg = 0
    var teacherAttitudeScoreSum = 0
    for score in self.teacherAttitudeArray {
        teacherAttitudeScoreSum += score
        teacherAttitudeScoreAvg = teacherAttitudeScoreSum / self.teacherAttitudeArray.count
    }
    
    var teacherManagingSatisfyScoreAvg = 0
    var teacherManagingSatisfyScoreSum = 0
    for score in self.teacherManagingSatisfyScoreArray {
        teacherManagingSatisfyScoreSum += score
        teacherManagingSatisfyScoreAvg = teacherManagingSatisfyScoreSum / self.teacherManagingSatisfyScoreArray.count
    }
    
    if (self.showModeEmail == "") {
        self.showModeEmail = (Auth.auth().currentUser?.email)!
    }
    
    db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                let uid = document.data()["uid"] as? String ?? ""
                
                self.db.collection("teacher").document(uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        
                        let eduText = data?["eduHistory"] as? String ?? "저장된 내용이 없습니다."
                        let classText = data?["classMethod"] as? String ?? "저장된 내용이 없습니다."
                        let extraText = data?["extraExprience"] as? String ?? "저장된 내용이 없습니다."
                        let time = data?["time"] as? String ?? "저장된 내용이 없습니다."
                        let contact = data?["contact"] as? String ?? "저장된 내용이 없습니다."
                        let manage = data?["manage"] as? String ?? "저장된 내용이 없습니다."
                        let portfolioShow = data?["portfolioShow"] as? String ?? "저장된 내용이 없습니다."
                        
                        if self.infos[indexPath.row] == "연락 수단" {
                            cell.content.text = contact
                        } else if self.infos[indexPath.row] == "학력사항" {
                            cell.content.text = eduText
                        } else if self.infos[indexPath.row] == "수업 방식" {
                            cell.content.text = classText
                        } else if self.infos[indexPath.row] == "과외 경력" {
                            cell.content.text = extraText
                        } else if self.infos[indexPath.row] == "선생님 평가" {
                            cell.content.text = "\(String(describing: self.teacherName.text!)) 선생님의 수업 태도는 평균적으로 \(teacherAttitudeScoreAvg)점이고, 학부모님들의 학생 관리 만족도는 평균적으로 \(teacherManagingSatisfyScoreAvg)점입니다." // 연결 필요
                        } else if self.infos[indexPath.row] == "과외 시간" {
                            cell.content.text = time
                        } else if self.infos[indexPath.row] == "학생 관리 방법" {
                            cell.content.text = manage
                        }
                        
                        if (portfolioShow == "Off" && self.isShowMode == true) {
                            let message = "비공개 설정 되어있습니다."
                            if self.infos[indexPath.row] == "연락 수단" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "학력사항" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "수업 방식" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "과외 경력" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "선생님 평가" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "과외 시간" {
                                cell.content.text = message
                            } else if self.infos[indexPath.row] == "학생 관리 방법" {
                                cell.content.text = message
                            }
                        }
                        cell.title.text = self.infos[indexPath.row]
                        
                        print("Document data: \(dataDescription)")
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
}

public func AddPortfolioFactors(title : String, content : String) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
        "\(title)": content
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func GetPortfolioPlots(self : PortfolioEditViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let eduHistory = data?["eduHistory"] as? String ?? ""
            self.eduHistoryTV.text = eduHistory
            // placeholder 설정
            if (self.eduHistoryTV.text == "") {
                self.placeholderSetting(self.eduHistoryTV)
                self.textViewDidBeginEditing(self.eduHistoryTV)
                self.textViewDidEndEditing(self.eduHistoryTV)
            }
            let classMethod = data?["classMethod"] as? String ?? ""
            self.classMetTV.text = classMethod
            // placeholder 설정
            if (self.classMetTV.text == "") {
                self.placeholderSetting(self.classMetTV)
                self.textViewDidBeginEditing(self.classMetTV)
                self.textViewDidEndEditing(self.classMetTV)
            }
            let extraExprience = data?["extraExprience"] as? String ?? ""
            self.extraExpTV.text = extraExprience
            // placeholder 설정
            if (self.extraExpTV.text == "") {
                self.placeholderSetting(self.extraExpTV)
                self.textViewDidBeginEditing(self.extraExpTV)
                self.textViewDidEndEditing(self.extraExpTV)
            }
            let manage = data?["manage"] as? String ?? ""
            self.manageTV.text = manage
            // placeholder 설정
            if (self.manageTV.text == "") {
                self.placeholderSetting(self.manageTV)
                self.textViewDidBeginEditing(self.manageTV)
                self.textViewDidEndEditing(self.manageTV)
            }
            let contact = data?["contact"] as? String ?? ""
            self.contactTV.text = contact
            // placeholder 설정
            if (self.contactTV.text == "") {
                self.placeholderSetting(self.contactTV)
                self.textViewDidBeginEditing(self.contactTV)
                self.textViewDidEndEditing(self.contactTV)
            }
            let time = data?["time"] as? String ?? ""
            self.timeTV.text = time
            // placeholder 설정
            if (self.timeTV.text == "") {
                self.placeholderSetting(self.timeTV)
                self.textViewDidBeginEditing(self.timeTV)
                self.textViewDidEndEditing(self.timeTV)
            }
            self.evaluationTV.text = "선생님이 수정할 수 없습니다."
            self.evaluationTV.isEditable = false
            
            let showPortfolio = data?["portfolioShow"] as? String ?? ""
            if (showPortfolio == "Off") {
                self.showPortfolio = "Off"
            } else {
                self.showPortfolio = "On"
            }
        } else {
            print("Document does not exist")
        }
    }
}

public func SaveEditedPlot(self : PortfolioEditViewController) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            
            let email = data?["email"] as? String ?? ""
            
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                "portfolioEmail": email
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
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").setData([
        "eduHistory": self.eduHistoryTV.text ?? "",
        "classMethod": self.classMetTV.text ?? "",
        "extraExprience": self.extraExpTV.text ?? "",
        "portfolioShow": self.showPortfolio,
        "time": self.timeTV.text ?? "",
        "manage": self.manageTV.text ?? "",
        "contact": self.contactTV.text ?? ""
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}
