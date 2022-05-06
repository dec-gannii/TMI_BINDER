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
import CryptoKit

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
