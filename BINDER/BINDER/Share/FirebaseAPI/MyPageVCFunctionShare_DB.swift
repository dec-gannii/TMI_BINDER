//
//  MyPageVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit
import Kingfisher

struct MyPageDBFunctions {
    var functionShare = FunctionShare()
    
    func ShowPortfolio(self : ShowPortfolioViewController) {
        // 입력된 이메일과 동일한 값을 가지는 이메일 필드가 있다면 수행
        db.collection("teacher").whereField("email", isEqualTo: self.teacherEmailTextField.text!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                // 도큐먼트 존재 안 하면 유효하지 않은 선생님 이메일이라고 alert 발생
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    functionShare.AlertShow(alertTitle: "탐색 오류", message: StringUtils.tEmailNotExist.rawValue, okTitle: "확인", self: self)
                    return
                }
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    print("\(document.documentID) => \(document.data())")
                    self.view.endEditing(true)
                    let email = data["email"] as? String ?? ""
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
    
    func GetUserInfoInPortfolioTableViewController(self : PortfolioTableViewController) {
        self.teacherAttitudeArray.removeAll()
        self.teacherManagingSatisfyScoreArray.removeAll()
        
        if (self.isShowMode == true) { /// 포트폴리오 조회인 경우
            self.editBtn.isEnabled = false
            db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        self.teacherName.text = data["name"] as? String ?? ""
                        self.teacherEmail.text = data["email"] as? String ?? ""
                        let profile = data["profile"] as? String ?? ""
                        let uid = data["uid"] as? String ?? ""
                        self.teacherUid = uid
                        
                        db.collection("teacherEvaluation").document(uid).collection("evaluation").whereField("teacherUid", isEqualTo: uid).getDocuments() {
                            (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let data = document.data()
                                    let teacherAttitude = data["teacherAttitude"] as? String ?? "0"
                                    if let attitudeScore = Int(teacherAttitude) {
                                        self.teacherAttitudeArray.append(attitudeScore)
                                    }
                                    let teacherManagingSatisfyScore = data["teacherManagingSatisfyScore"] as? String ?? "0"
                                    if let manageScore = Int(teacherManagingSatisfyScore) {
                                        self.teacherManagingSatisfyScoreArray.append(manageScore)
                                    }
                                }
                            }
                        }
                        
                        self.infos.removeAll() // 원래 있는 제목 정보들 모두 지우기
                        
                        db.collection("teacher").document(uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let eduText = data?["eduHistory"] as? String ?? "" // 학력 정보
                                let classText = data?["classMethod"] as? String ?? "" // 수업 방식
                                let extraText = data?["extraExprience"] as? String ?? "" // 과외 경력
                                let time = data?["time"] as? String ?? "" // 과외 시간
                                let contact = data?["contact"] as? String ?? "" // 연락 수단
                                let manage = data?["manage"] as? String ?? "" // 학생 관리 방법
                                let memo = data?["memo"] as? String ?? "" // 메모
                                
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
                                if (memo != "") {
                                    self.infos.append("메모")
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
            self.editBtn.isEnabled = true
            if let image = UIImage(named: "pencil") {
                self.editBtn.setImage(image, for: .normal)
                self.editBtn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
            self.infos.removeAll()
            self.teacherAttitudeArray.removeAll()
            self.teacherManagingSatisfyScoreArray.removeAll()
            
            db.collection("teacherEvaluation").document(Auth.auth().currentUser!.uid).collection("evaluation").whereField("teacherUid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() {
                (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let teacherAttitude = data["teacherAttitude"] as? String ?? "0"
                        if let attitudeScore = Int(teacherAttitude) {
                            self.teacherAttitudeArray.append(attitudeScore)
                        }
                        let teacherManagingSatisfyScore = data["teacherManagingSatisfyScore"] as? String ?? "0"
                        if let manageScore = Int(teacherManagingSatisfyScore) {
                            self.teacherManagingSatisfyScoreArray.append(manageScore)
                        }
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
                    let memo = data?["memo"] as? String ?? ""
                    
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
                    if (memo != "") {
                        self.infos.append("메모")
                    }
                    self.infos.append("선생님 평가")
                }
            }
            
            db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = data.map(String.init(describing:)) ?? "nil"
                    self.teacherName.text = LoginRepository.shared.teacherItem!.name
                    self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
                    self.teacherImage.kf.setImage(with: URL(string: LoginRepository.shared.teacherItem!.profile)!)
                    self.teacherImage.makeCircle()
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func GetPortfolioFactors(self : PortfolioTableViewController, indexPath : IndexPath, cell : PortfolioDefaultCell) {
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
                    
                    db.collection("teacher").document(uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let dataDescription = data.map(String.init(describing:)) ?? "nil"
                            let eduText = data?["eduHistory"] as? String ?? ""
                            let classText = data?["classMethod"] as? String ?? ""
                            let extraText = data?["extraExprience"] as? String ?? ""
                            let time = data?["time"] as? String ?? ""
                            let contact = data?["contact"] as? String ?? ""
                            let manage = data?["manage"] as? String ?? ""
                            let portfolioShow = data?["portfolioShow"] as? String ?? ""
                            let memo = data?["memo"] as? String ?? ""
                            
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
                            } else if self.infos[indexPath.row] == "메모" {
                                cell.content.text = memo
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
                                } else if self.infos[indexPath.row] == "메모" {
                                    cell.content.text = memo
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
    
    func AddPortfolioFactors(title : String, content : String) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
            "\(title)": content
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func GetPortfolioPlots(self : PortfolioEditViewController) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let eduHistory = data?["eduHistory"] as? String ?? ""
                self.eduHistoryTV.text = eduHistory
                // placeholder 설정
                if (self.eduHistoryTV.text == "") {
                    self.placeholderSetting(self.classMetTV)
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
                let memo = data?["memo"] as? String ?? ""
                self.memoTV.text = memo
                // placeholder 설정
                if (self.memoTV.text == "") {
                    self.placeholderSetting(self.memoTV)
                    self.textViewDidBeginEditing(self.memoTV)
                    self.textViewDidEndEditing(self.memoTV)
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
                self.placeholderSetting(self.memoTV)
                self.placeholderSetting(self.timeTV)
                self.placeholderSetting(self.contactTV)
                self.placeholderSetting(self.manageTV)
                self.placeholderSetting(self.extraExpTV)
                self.placeholderSetting(self.classMetTV)
                self.placeholderSetting(self.eduHistoryTV)
                
                self.evaluationTV.text = "선생님이 수정할 수 없습니다."
                self.evaluationTV.isEditable = false
            }
        }
    }
    
    func SaveEditedPlot(self : PortfolioEditViewController) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = data.map(String.init(describing:)) ?? "nil"
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
        
        if (self.eduHistoryTV.text == StringUtils.eduHistoryPlaceHolder.rawValue) {
            self.eduHistoryTV.text = ""
        }
        if (self.classMetTV.text == StringUtils.classMethodPlaceHolder.rawValue) {
            self.classMetTV.text = ""
        }
        if (self.extraExpTV.text == StringUtils.extraExperiencePlaceHolder.rawValue) {
            self.extraExpTV.text = ""
        }
        if (self.timeTV.text == StringUtils.timePlaceHolder.rawValue) {
            self.timeTV.text = ""
        }
        if (self.manageTV.text == StringUtils.managePlaceHolder.rawValue) {
            self.manageTV.text = ""
        }
        if (self.contactTV.text == StringUtils.contactPlaceHolder.rawValue) {
            self.contactTV.text = ""
        }
        if (self.memoTV.text == StringUtils.memoPlaceHolder.rawValue) {
            self.memoTV.text = ""
        }
        let array = [
            "eduHistory": self.eduHistoryTV.text ?? "",
            "classMethod": self.classMetTV.text ?? "",
            "extraExprience": self.extraExpTV.text ?? "",
            "portfolioShow": self.showPortfolio,
            "memo": self.memoTV.text ?? "",
            "time": self.timeTV.text ?? "",
            "manage": self.manageTV.text ?? "",
            "contact": self.contactTV.text ?? ""
        ]
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").setData(array) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func PortfolioToggleButtonClicked(self : MyPageViewController) {
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
    
    func SaveImage(self : MyPageViewController) {
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
                    
                    db.collection(self.type).document(Auth.auth().currentUser!.uid).updateData([
                        "profile":"\(downloadURL)",
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                    if (self.type == "teacher") {
                        LoginRepository.shared.teacherItem!.profile = "\(downloadURL)"
                        LoginRepository.shared.teacherItem!.profile = "\(downloadURL)"
                    } else if (self.type == "student") {
                        LoginRepository.shared.studentItem!.profile = "\(downloadURL)"
                        LoginRepository.shared.studentItem!.profile = "\(downloadURL)"
                    }
                }
            }
        }
    }
    
    func GetUserInfoForMyPage(self : MyPageViewController) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                LoginRepository.shared.doLogin {
                    self.portolioLabel.isHidden = false
                    self.nameLabel.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
                    self.portfolioNameLabel.text = "\(LoginRepository.shared.teacherItem!.name)"
                    self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
                    self.type = LoginRepository.shared.teacherItem!.type
                    let url = URL(string: LoginRepository.shared.teacherItem!.profile)!
                    self.imageView.kf.setImage(with: url)
                    self.imageView.makeCircle()
                    self.pageViewTitleLabel.text = "열람 여부"
                } failure: { error in
                    self.showDefaultAlert(msg: "")
                }
            } else {
                db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        self.nameLabel.text = "\(LoginRepository.shared.studentItem!.name) 학생"
                        self.portfolioNameLabel.text = LoginRepository.shared.studentItem!.name
                        self.teacherEmail.text = LoginRepository.shared.studentItem!.email
                        self.type = LoginRepository.shared.studentItem!.type
                        let url = URL(string: LoginRepository.shared.studentItem!.profile)!
                        
                        let pageViewContentLabel = UILabel(frame: CGRect(x: 60, y: 15, width: 230, height: 17))
                        pageViewContentLabel.text = LoginRepository.shared.studentItem!.goal
                        
                        self.imageView.kf.setImage(with: url)
                        self.imageView.makeCircle()
                        self.openPortfolioSwitch.removeFromSuperview()
                        self.portfoiolBtn.removeFromSuperview()
                        self.portolioLabel.isHidden = true
                        self.pageViewTitleLabel.text = "목표"
                        
                        self.whiteBGOnView.addSubview(pageViewContentLabel)
                        
                        pageViewContentLabel.numberOfLines = 1
                        pageViewContentLabel.textAlignment = .left
                        pageViewContentLabel.textColor = .gray4
                        pageViewContentLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    func GetPortfolioShow(self : MyPageViewController) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = data.map(String.init(describing:)) ?? "nil"
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
}
