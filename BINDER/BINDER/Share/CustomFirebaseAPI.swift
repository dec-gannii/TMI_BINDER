//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import FirebaseStorage
import CryptoKit

public var sharedCurrentPW : String = ""
public var userType : String = ""

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

/// 로그인을 위한 DB 메소드들

public func LogInAndShowHomeVC (email : String, password: String, self : LogInViewController) {
    let db = Firestore.firestore()
    // 별 오류 없으면 로그인 되어서 홈 뷰 컨트롤러 띄우기
    db.collection("parent").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                // 사용할 것들 가져와서 지역 변수로 저장
                guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                self.present(tb, animated: true, completion: nil)
                return
            }
            
            guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                //아니면 종료
                return
            }
            
            // 아이디와 비밀번호 정보 넘겨주기
            homeVC.pw = password
            homeVC.id = email
            if (Auth.auth().currentUser?.isEmailVerified == true){
                homeVC.verified = true
            } else { homeVC.verified = false }
            
            guard let myClassVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                //아니면 종료
                return
            }
            
            guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                return
            }
            guard let myPageVC =
                    self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                return
            }
            
            // tab bar 설정
            let tb = UITabBarController()
            tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
            self.present(tb, animated: true, completion: nil)
        }
    }
}

public func GoogleLogIn(googleCredential : AuthCredential, self : LogInViewController) {
    Auth.auth().signIn(with: googleCredential) {
        (authResult, error) in if let error = error {
            print("Firebase sign in error: \(error)")
            return
        } else {
            guard let TypeSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController") as? TypeSelectViewController else {
                //아니면 종료
                return
            }
            
            //화면전환
            if ((Auth.auth().currentUser) != nil) {
                // 홈 화면으로 바로 이동
                guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                    //아니면 종료
                    return
                }
                
                if (Auth.auth().currentUser?.isEmailVerified == true){
                    homeVC.verified = true
                } else { homeVC.verified = false }
                
                //화면전환
                guard let myClassVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                    //아니면 종료
                    return
                }
                
                guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                    return
                }
                guard let myPageVC =
                        self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                    return
                }
                
                // tab bar 설정
                let tb = UITabBarController()
                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
                self.present(tb, animated: true, completion: nil)
                
                self.isLogouted = false
            } else {
                TypeSelectVC.isGoogleSignIn = true
                TypeSelectVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                TypeSelectVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(TypeSelectVC, animated: true)
            }
        }
    }
}

public func AppleLogIn(credential : OAuthCredential, self : LogInViewController) {
    let db = Firestore.firestore()
    // Sign in with Firebase.
    Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
        if (error != nil) {
            print("ERROR : \(error)")
            return
        } else {
            Firestore.firestore().collection("teacher").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let email = document.data()["email"] as? String ?? ""
                        let password = document.data()["password"] as? String ?? ""
                        
                        guard let homeVC = self?.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                            //아니면 종료
                            return
                        }
                        
                        // 아이디와 비밀번호 정보 넘겨주기
                        homeVC.pw = password
                        homeVC.id = email
                        
                        if (Auth.auth().currentUser?.isEmailVerified == true){
                            homeVC.verified = true
                        } else { homeVC.verified = false }
                        
                        guard let myClassVC = self?.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                            //아니면 종료
                            return
                        }
                        
                        guard let questionVC = self?.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                            return
                        }
                        guard let myPageVC =
                                self?.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                            return
                        }
                        
                        // tab bar 설정
                        let tb = UITabBarController()
                        tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
                        self!.present(tb, animated: true, completion: nil)
                        
                    }
                    Firestore.firestore().collection("student").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                
                                let email = document.data()["email"] as? String ?? ""
                                let password = document.data()["password"] as? String ?? ""
                                
                                guard let homeVC = self?.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                                    //아니면 종료
                                    return
                                }
                                
                                // 아이디와 비밀번호 정보 넘겨주기
                                homeVC.pw = password
                                homeVC.id = email
                                
                                if (Auth.auth().currentUser?.isEmailVerified == true){
                                    homeVC.verified = true
                                } else { homeVC.verified = false }
                                
                                guard let myClassVC = self?.storyboard?.instantiateViewController(withIdentifier: "MyClassViewController") as? MyClassVC else {
                                    //아니면 종료
                                    return
                                }
                                
                                guard let questionVC = self?.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
                                    return
                                }
                                guard let myPageVC =
                                        self?.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                                    return
                                }
                                
                                // tab bar 설정
                                let tb = UITabBarController()
                                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
                                self!.present(tb, animated: true, completion: nil)
                            }
                            Firestore.firestore().collection("parent").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        
                                        guard let tb = self?.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                                        tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                        self!.present(tb, animated: true, completion: nil)
                                        
                                        return
                                    }
                                    // type select 화면으로 이동
                                    guard let typeSelectVC = self?.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController") as? TypeSelectViewController else { return }
                                    typeSelectVC.modalPresentationStyle = .fullScreen
                                    typeSelectVC.modalTransitionStyle = .crossDissolve
                                    typeSelectVC.name = Auth.auth().currentUser?.displayName ?? ""
                                    typeSelectVC.email = Auth.auth().currentUser?.email ?? ""
                                    typeSelectVC.isAppleLogIn = true
                                    
                                    self!.present(typeSelectVC, animated: true, completion: nil)
                                    return
                                }
                            }
                        }
                        return
                    }
                }
                return
            }
        }
    }
}

public func DeleteUser(self : StudentSubInfoController) {
    let user = Auth.auth().currentUser // 사용자 정보 가져오기
    let db = Firestore.firestore()
    
    user?.delete { error in
        if let error = error {
            // An error happened.
            print("delete user error : \(error)")
        } else {
            // Account deleted.
            // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
            var docRef = db.collection("teacher").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("student").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("parent").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
}

public func UpdateStudentSubInfo(age : String, phonenum : String, goal : String) {
    let db = Firestore.firestore()
    db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
        "age": age,
        "phonenum": phonenum,
        "goal": goal
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func UpdateTeacherSubInfo(parentPW : String) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
        "parentPW": parentPW
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func CheckStudentPhoneNumberForParent(phoneNumber: String, self: StudentSubInfoController, goal : String) {
    let db = Firestore.firestore()
    db.collection("teacher").whereField("email", isEqualTo: goal).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                return
            }
            for document in querySnapshot!.documents {
                // 선생님 비밀번호
                self.tpassword = document.data()["parentPW"] as? String ?? ""
                
                if self.phonenum == "" {
                    self.phoneAlertLabel.text = "전화번호를 작성해주세요."
                    self.phoneAlertLabel.isHidden = false
                }
                else if ((self.phonenumTextField.text!.contains("-") && self.phonenumTextField.text!.count >= 15) || (self.phonenumTextField.text!.count >= 12 && !self.phonenumTextField.text!.contains("-"))) {
                    self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                    self.phoneAlertLabel.isHidden = false
                }
                else if self.tpassword != self.ageShowPicker.text! {
                    self.ageAlertLabel.text = StringUtils.tEmailNotMatch.rawValue
                    self.ageAlertLabel.isHidden = false
                }
                else {
                    self.goalAlertLabel.isHidden = true
                    self.phoneAlertLabel.isHidden = true
                    self.ageAlertLabel.isHidden = true
                    
                    if phoneNumber != ""{
                        db.collection("student").whereField("phonenum", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                                self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                                self.phoneAlertLabel.isHidden = false
                            } else {
                                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                    return
                                }
                                for document in querySnapshot!.documents {
                                    var sphonenum = document.data()["phonenum"] as? String ?? ""
                                    
                                    if sphonenum == phoneNumber {
                                        db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                                            "teacherEmail": self.goal,
                                            "childPhoneNumber": phoneNumber                ]) { err in
                                                if let err = err {
                                                    print("Error adding document: \(err)")
                                                }
                                            }
                                        
                                        guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                                        tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                        self.present(tb, animated: true, completion: nil)
                                    } else {
                                        self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                                        self.phoneAlertLabel.isHidden = false
                                    }
                                }
                            }
                        }
                    }
                    
                    else {
                        self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                        self.phoneAlertLabel.isHidden = false
                    }
                }
            }
        }
    }
}

public func SaveInfoForSignUp (self : SignInViewController, number: Int, name: String, email: String, password: String, type: String) {
    let db = Firestore.firestore()
    db.collection("\(type)").document(Auth.auth().currentUser!.uid).setData([
        "name": name,
        "email": email,
        "password": password,
        "type": type,
        "uid": Auth.auth().currentUser?.uid,
        "profile": Auth.auth().currentUser?.photoURL?.absoluteString ?? "https://ifh.cc/g/Lt9Ip8.png"
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
    
    guard let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfoController") as? StudentSubInfoController else {
        //아니면 종료
        return
    }
    subInfoVC.type = type
    subInfoVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
    subInfoVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
    self.present(subInfoVC, animated: true, completion: nil)
}

public func DeleteUserWhileSignUp () {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser // 사용자 정보 가져오기
    
    user?.delete { error in
        if let error = error {
            // An error happened.
            print("delete user error : \(error)")
        } else {
            // Account deleted.
            // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
            var docRef = db.collection("teacher").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("student").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            docRef = db.collection("parent").document(user!.uid)
            
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
}

public func CreateUser(type : String, self : SignInViewController, name : String, id : String, pw : String) {
    let db = Firestore.firestore()
    db.collection(type).whereField("email", isEqualTo: id).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                self.emailAlertLabel.text = StringUtils.emailExistAlert.rawValue
                self.emailAlertLabel.isHidden = false
                self.emailTextField.text = ""
                return
            }
            
            if self.emailAlertLabel.isHidden == true {
                // 이름, 이메일, 비밀번호, 나이가 모두 유효하다면, && self.isValidAge(age)
                if (self.isValidName(name) && self.isValidEmail(id) && self.isValidPassword(pw) ) {
                    // 사용자를 생성
                    Auth.auth().createUser(withEmail: id, password: pw) {(authResult, error) in
                        if (type != "parent"){
                            Auth.auth().currentUser?.sendEmailVerification(completion: {(error) in
                                print("sended to " + id)
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                }
                            })
                        }
                        
                        // 정보 저장
                        SaveInfoForSignUp(self: self, number: SignInViewController.number, name: name, email: id, password: pw, type: self.type)
                        SignInViewController.number = SignInViewController.number + 1
                        guard let user = authResult?.user else {
                            return
                        }
                    }
                } else {
                    if (self.isGoogleSignIn == false) {
                        // 유효하지 않다면, 에러가 난 부분 label로 알려주기 위해 error label 숨김 해제
                        if (!self.isValidEmail(id)){
                            self.emailAlertLabel.isHidden = false
                            self.emailAlertLabel.text = StringUtils.emailValidationAlert.rawValue
                        }
                        if (!self.isValidPassword(pw)) {
                            self.pwAlertLabel.isHidden = false
                            self.pwAlertLabel.text = StringUtils.passwordValidationAlert.rawValue
                        }
                    } else {
                        // 정보 저장
                        SaveInfoForSignUp(self: self, number: SignInViewController.number, name: name, email: id, password: pw, type: type)
                        SignInViewController.number = SignInViewController.number + 1
                        
                        // 추가 정보를 입력하는 뷰로 이동
                        guard let subInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentSubInfoController") as? StudentSubInfoController else {
                            //아니면 종료
                            return
                        }
                        subInfoVC.type = type
                        subInfoVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        subInfoVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                        self.present(subInfoVC, animated: true, completion: nil)
                    }
                    if (!self.isValidName(name)) {
                        self.nameAlertLabel.isHidden = false
                        self.nameAlertLabel.text = StringUtils.nameValidationAlert.rawValue
                    }
                }
            }
        }
    }
}

/// 나의 수업을 위한 DB 메소드들

public func GetUserInfoForClassList(self : MyClassVC) {
    let db = Firestore.firestore()
    db.collection("teacher").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            if let err = err {
                print("Error getting documents(inMyClassView): \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let type = document.data()["type"] as? String ?? ""
                    self.type = type
                    let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                    
                    let url = URL(string: profile)!
                    self.teacherImage.kf.setImage(with: url)
                    self.setTeacherInfo()
                    
                    LoadingHUD.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        LoadingHUD.hide()
                    }
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
                    self.type = type
                    
                    let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                    let url = URL(string: profile)!
                    self.teacherImage.kf.setImage(with: url)
                    
                    self.setStudentInfo()
                    
                    LoadingHUD.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        LoadingHUD.hide()
                    }
                }
            }
        }
    }
}

public func SetMyClasses(self : MyClassVC) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
            self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
        } else {
            /// nil이 아닌지 확인한다.
            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                        self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
                    } else {
                        /// nil이 아닌지 확인한다.
                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                            
                            return
                        }
                        
                        /// 조회하기 위해 원래 있던 것 들 다 지움
                        self.classItems.removeAll()
                        
                        for document in snapshot.documents {
                            print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                            
                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                            let classDt = document.data()
                            
                            self.type = "student"
                            /// nil값 처리
                            let email = classDt["email"] as? String ?? ""
                            let name = classDt["name"] as? String ?? ""
                            let goal = classDt["goal"] as? String ?? ""
                            let subject = classDt["subject"] as? String ?? ""
                            let currentCnt = classDt["currentCnt"] as? Int ?? 0
                            let totalCnt = classDt["totalCnt"] as? Int ?? 0
                            let classColor = classDt["circleColor"] as? String ?? "026700"
                            let recentDate = classDt["recentDate"] as? String ?? ""
                            let payType = classDt["payType"] as? String ?? ""
                            let payDate = classDt["payDate"] as? String ?? ""
                            let payAmount = classDt["payAmount"] as? String ?? ""
                            let schedule = classDt["schedule"] as? String ?? ""
                            let repeatYN = classDt["repeatYN"] as? String ?? ""
                            let index = classDt["index"] as? Int ?? 0
                            
                            self.studentEmail = email
                            
                            let item = ClassItem(email: email, name: name, goal: goal, subject: subject, recentDate: recentDate, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: classColor, payType: payType, payDate: payDate, payAmount: payAmount, schedule: schedule, repeatYN: repeatYN, index: index)
                            
                            /// 모든 값을 더한다.
                            self.classItems.append(item)
                        }
                        
                        /// UITableView를 reload 하기
                        self.studentTV.reloadData()
                    }
                }
                return
            }
            /// 조회하기 위해 원래 있던 것 들 다 지움
            self.classItems.removeAll()
            
            
            for document in snapshot.documents {
                print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                
                /// document.data()를 통해서 값 받아옴, data는 dictionary
                let classDt = document.data()
                
                self.type = "teacher"
                /// nil값 처리
                let email = classDt["email"] as? String ?? ""
                let name = classDt["name"] as? String ?? ""
                let goal = classDt["goal"] as? String ?? ""
                let subject = classDt["subject"] as? String ?? ""
                let currentCnt = classDt["currentCnt"] as? Int ?? 0
                let totalCnt = classDt["totalCnt"] as? Int ?? 0
                let classColor = classDt["circleColor"] as? String ?? "026700"
                let recentDate = classDt["recentDate"] as? String ?? ""
                let payType = classDt["payType"] as? String ?? ""
                let payDate = classDt["payDate"] as? String ?? ""
                let payAmount = classDt["payAmount"] as? String ?? ""
                let schedule = classDt["schedule"] as? String ?? ""
                let repeatYN = classDt["repeatYN"] as? String ?? ""
                let index = classDt["index"] as? Int ?? 0
                
                let item = ClassItem(email: email, name: name, goal: goal, subject: subject, recentDate: recentDate, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: classColor, payType: payType, payDate: payDate, payAmount: payAmount, schedule: schedule, repeatYN: repeatYN, index: index)
                
                /// 모든 값을 더한다.
                self.classItems.append(item)
            }
            
            /// UITableView를 reload 하기
            self.studentTV.reloadData()
        }
    }
}

public func MoveToDetailClassVC (self : MyClassVC, sender : UIButton) {
    var index: Int!
    var name: String!
    var email: String!
    var subject: String!
    var type: String!
    
    let db = Firestore.firestore()
    /// 입력한 이메일과 갖고있는 이메일이 같은지 확인
    var docRef: CollectionReference
    if (self.type == "teacher") {
        docRef = db.collection("teacher")
    } else {
        docRef = db.collection("student")
    }
    
    docRef.document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: sender.tag)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                
                guard let weekendVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController") as? DetailClassViewController else { return }
                
                weekendVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                weekendVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                /// first : 여러개가 와도 첫번째 것만 봄.
                
                let studentDt = snapshot.documents.first!.data()
                
                if (self.type == "teacher") {
                    index = studentDt["index"] as? Int ?? 0
                    name = studentDt["name"] as? String ?? ""
                    subject = studentDt["subject"] as? String ?? ""
                    type = "teacher"
                } else if (self.type == "student") {
                    let teacherDt = snapshot.documents.first!.data()
                    index = teacherDt["index"] as? Int ?? 0
                    name = teacherDt["name"] as? String ?? ""
                    type = "student"
                    subject = teacherDt["subject"] as? String ?? ""
                }
                email = studentDt["email"] as? String ?? ""
                
                weekendVC.userIndex = index
                weekendVC.userEmail = email
                weekendVC.userName = name
                weekendVC.userType = type
                weekendVC.userSubject = subject
                
                self.present(weekendVC, animated: true, completion: nil)
            }
        }
}


public func SearchStudent(self : AddStudentVC, email : String) {
    let db = Firestore.firestore()
    /// 입력한 이메일과 갖고있는 이메일이 같은지 확인
    db.collection("student").whereField("email", isEqualTo: email)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "학생을 찾는 중 에러가 발생했습니다.")
            } else {
                
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    self.showDefaultAlert(msg: "해당하는 학생이 존재하지 않습니다.")
                    return
                }
                
                /// first : 여러개가 와도 첫번째 것만 봄.
                let studentDt = snapshot.documents.first!.data()
                let age = studentDt["age"] as? Int ?? 0
                let email = studentDt["email"] as? String ?? ""
                let goal = studentDt["goal"] as? String ?? ""
                let name = studentDt["name"] as? String ?? ""
                let password = studentDt["password"] as? String ?? ""
                let phone = studentDt["phone"] as? String ?? ""
                let profile = studentDt["profile"] as? String ?? ""
                let item = StudentItem(age: age, email: email, goal: goal, name: name, password: password, phone: phone, profile: profile)
                
                /// 값 넘어가기
                self.performSegue(withIdentifier: "inputClassSegue", sender: item)
            }
            /// 변수 다시 공백으로 바꾸기
            self.emailTf.text = ""
        }
}

public func GetStudentClassCount(self : ClassInfoVC, uid : String) {
    let db = Firestore.firestore()
    self.studentCount = 0
    db.collection("student").document(uid).collection("class").getDocuments()
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
                print("student \(document.documentID) => \(document.data())");
            }
            if (count > 0) {
                db.collection("student").document(uid).collection("class").document("\(LoginRepository.shared.teacherItem!.name)(\(LoginRepository.shared.teacherItem!.email)) " + self.subjectTextField.text!).updateData(["index": count-1])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            }
        }
    }
}

public func GetTeacherClassCount(self : ClassInfoVC) {
    let db = Firestore.firestore()
    self.studentCount = 0
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments()
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
            if (count > 0) {
                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.studentItem.name + "(" + self.studentItem.email + ") " + self.subjectTextField.text!).updateData(["index": count-1])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                
            }
        }
    }
}

public func SaveClassInfo(self : ClassInfoVC, subject : String, payDate : String, payment : String , schedule : String) {
    // 데이터베이스 연결
    var studentUid = ""
    let db = Firestore.firestore()
    
    db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments {
        (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                db.collection("student").whereField("email", isEqualTo: "\(self.studentItem.email)").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                studentUid = document.data()["uid"] as? String ?? ""
                                
                                db.collection("student").document(studentUid).collection("class").document("\(LoginRepository.shared.teacherItem!.name)(\(LoginRepository.shared.teacherItem!.email)) " + self.subjectTextField.text!).setData([
                                    "email" : "\(LoginRepository.shared.teacherItem!.email)",
                                    "name" : "\(LoginRepository.shared.teacherItem!.name)",
                                    "subject" : self.subjectTextField.text!,
                                    "currentCnt" : 0,
                                    "totalCnt" : 8,
                                    "circleColor" : self.classColor1,
                                    "recentDate" : "",
                                    "datetime": Date().formatted(),
                                    "goal": self.studentItem.goal])
                                { err in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                        self.showDefaultAlert(msg: "수업 저장 중에 에러가 발생했습니다.")
                                    }
                                }
                            }
                            GetStudentClassCount(self: self, uid: studentUid)
                        }
                    }
                }
            }
        }
    }
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.studentItem.name + "(" + self.studentItem.email + ") " + self.subjectTextField.text!).setData([
        "email" : self.studentItem.email,
        "name" : self.studentItem.name,
        "goal" : self.studentItem.goal,
        "subject" : subject,
        "currentCnt" : 0,
        "totalCnt" : 8,
        "circleColor" : self.classColor1,
        "recentDate" : "",
        "payType" : self.payType == .timly ? "T" : "C",
        "payDate": payDate,
        "payAmount": payment,
        "schedule" : schedule,
        "repeatYN": self.isRepeat.isOn,
        "datetime": Date().formatted()])
    { err in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
            self.showDefaultAlert(msg: "수업 저장 중에 에러가 발생했습니다.")
        } else {
            // 데이타 저장에 성공한 경우 처리
            ///  dissmiss 닫음
            /// completion :클로저
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                self.delegate?.onSuccess()
            })
        }
    }
}

public func UpdateClassInfo(self : EditClassVC, schedule : String) {
    let db = Firestore.firestore()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).updateData([
        "subject": self.subjectTF.text ?? "None",
        "payType": self.payType == .timly ? "T" : "C",
        "payAmount": self.payAmountTF.text ?? "None",
        "payDate": self.payDateTF.text ?? "None",
        "repeatYN": self.repeatYN ,
        "schedule": schedule
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func GetClassInfo(self : EditClassVC) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.userEmail + ") " + self.userSubject).getDocument { [self] (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            
            let subject = data?["subject"] as? String ?? ""
            self.subjectTF.text = subject
            
            let payType = data?["payType"] as? String ?? ""
            if (payType == "C") {
                self.payTypeBtn.setTitle("회차별", for: .normal)
            } else {
                self.payTypeBtn.setTitle("시간별", for: .normal)
            }
            
            let payAmount = data?["payAmount"] as? String ?? ""
            self.payAmountTF.text = payAmount
            
            let payDate = data?["payDate"] as? String ?? ""
            self.payDateTF.text = payDate
            
            let repeatYN = data?["repeatYN"] as? Bool ?? true
            if (repeatYN == true) {
                self.repeatYNToggle.setOn(true, animated: true)
            } else {
                self.repeatYNToggle.setOn(false, animated: true)
            }
            
            let schedule = data?["schedule"] as? String ?? ""
            // 저장된 스케줄을 " " 단위로 갈라내어 배열로 저장함
            self.days = schedule.components(separatedBy: " ")
            print(self.days)
            
            if self.days.contains("월") {
                self.daysBtn[0].isSelected = true
            }
            if self.days.contains("화") {
                self.daysBtn[1].isSelected = true
            }
            if self.days.contains("수") {
                self.daysBtn[2].isSelected = true
            }
            if self.days.contains("목") {
                self.daysBtn[3].isSelected = true
            }
            if self.days.contains("금") {
                self.daysBtn[4].isSelected = true
            }
            if self.days.contains("토") {
                self.daysBtn[5].isSelected = true
            }
            if self.days.contains("일") {
                self.daysBtn[6].isSelected = true
            }
        } else {
            print("Document does not exist")
        }
    }
}

/// 설정을 위한 DB 메소드들

public func Secession(self : SecessionViewController) {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser // 사용자 정보 가져오기
    
    user?.delete { error in
        if let error = error {
            // An error happened.
            print("delete user error : \(error)")
        } else {
            // Account deleted.
            // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
            db.collection("teacher").document(user!.uid).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            db.collection("student").document(user!.uid).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            db.collection("parent").document(user!.uid).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
        print("delete success, go sign in page")
        
        // 로그인 화면(첫화면)으로 다시 이동
        guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
    }
}

public func GetPW() {
    let db = Firestore.firestore()
    
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
            sharedCurrentPW = data?["password"] as? String ?? ""
        } else {
            // 먼저 설정한 선생님 정보의 uid의 경로가 없다면 학생 정보에서 재탐색
            db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                    sharedCurrentPW = data?["password"] as? String ?? ""
                } else {
                    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                            sharedCurrentPW = data?["password"] as? String ?? ""
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
}

public func SaveTeacherInfos(name : String, password : String , parentPW : String) {
    let db = Firestore.firestore()
    // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
    db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
        "name": name,
        "password": password,
        "parentPW": parentPW
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func SaveStudentInfos(name : String, password : String , parentPassword : UITextField) {
    let db = Firestore.firestore()
    // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
    db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
        "name": name,
        "password": password,
        "goal": parentPassword.text!
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func SaveParentInfos (name : String, password : String, childPhoneNumber : String) {
    let db = Firestore.firestore()
    // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
    db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
        "name": name,
        "password": password,
        "childPhoneNumber": childPhoneNumber
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}

public func GetUserInfoForEditInfo(nameTF : UITextField, emailLabel : UILabel, parentPassword : UITextField, parentPasswordLabel : UILabel) {
    let db = Firestore.firestore()
    db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            // 이름, 이메일, 학부모 인증용 비밀번호, 사용자의 타입
            let userName = data?["name"] as? String ?? ""
            nameTF.text = userName
            let userEmail = data?["email"] as? String ?? ""
            emailLabel.text = userEmail
            let parentPW = data?["parentPW"] as? String ?? ""
            parentPassword.text = parentPW
            userType = data?["type"] as? String ?? ""
            sharedCurrentPW = data?["password"] as? String ?? ""
        } else {
            // 현재 사용자에 해당하는 선생님 문서가 없으면 학생 문서로 다시 검색
            db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let userName = data?["name"] as? String ?? ""
                    nameTF.text = userName
                    let userEmail = data?["email"] as? String ?? ""
                    emailLabel.text = userEmail
                    userType = data?["type"] as? String ?? ""
                    sharedCurrentPW = data?["password"] as? String ?? ""
                    let goal = data?["goal"] as? String ?? ""
                    parentPasswordLabel.text = "목표"
                    parentPassword.text = goal
                } else {
                    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let userName = data?["name"] as? String ?? ""
                            nameTF.text = userName
                            let userEmail = data?["email"] as? String ?? ""
                            emailLabel.text = userEmail
                            userType = data?["type"] as? String ?? ""
                            sharedCurrentPW = data?["password"] as? String ?? ""
                            parentPasswordLabel.text = "자녀 휴대전화 번호"
                            let childPhoneNumber = data?["childPhoneNumber"] as? String ?? ""
                            parentPassword.text = childPhoneNumber
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
}

/// 포트폴리오를 위한 DB 메소드들

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
