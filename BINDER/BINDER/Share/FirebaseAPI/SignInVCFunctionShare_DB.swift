//
//  SignInVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import UIKit

struct SignInVCDBFunctions {
    var functionShare = FunctionShare()
    
    func SaveInfoForSignUp (self : SignInViewController, number: Int, name: String, email: String, password: String, type: String) {
        var profileImage = ""
        
        if (type == "student") {
            profileImage = "https://i.postimg.cc/4xbWLCKh/student-profile.png"
        } else if (type == "parent") {
            profileImage = "https://i.postimg.cc/Z5hfxYqS/parent-profile.png"
        } else if (type == "teacher") {
            profileImage = "https://i.postimg.cc/9XKgzY5z/teacher-profile.png"
        }
        
        db.collection("\(type)").document(Auth.auth().currentUser!.uid).setData([
            "name": name,
            "email": email,
            "password": password,
            "type": type,
            "uid": Auth.auth().currentUser?.uid,
            "profile": Auth.auth().currentUser?.photoURL?.absoluteString ?? profileImage,
            "fcmToken": Messaging.messaging().fcmToken
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        
        guard let emailVerificationVC = self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController else {
            //아니면 종료
            return
        }
        emailVerificationVC.type = type
        emailVerificationVC.email = email
        emailVerificationVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        emailVerificationVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(emailVerificationVC, animated: true, completion: nil)
    }
    
    func DeleteUserWhileSignUp () {
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
    
    func CreateUser(type : String, self : SignInViewController, name : String, id : String, pw : String) {
        db.collection(type).whereField("email", isEqualTo: id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                functionShare.AlertShow(alertTitle: "계정 오류", message: "이미 존재하는 계정입니다!", okTitle: "확인", self: self)
                return
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
                    if (self.isValidPassword(pw)) {
                        // 사용자를 생성
                        Auth.auth().createUser(withEmail: id, password: pw) {(authResult, error) in
                            Auth.auth().currentUser?.sendEmailVerification()
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
                            if (!self.isValidPassword(pw)) {
                                self.pwAlertLabel.isHidden = false
                                self.pwAlertLabel.text = StringUtils.passwordValidationAlert.rawValue
                            }
                        } else {
                            // 정보 저장
                            SaveInfoForSignUp(self: self, number: SignInViewController.number, name: name, email: id, password: pw, type: type)
                            SignInViewController.number = SignInViewController.number + 1
                            
                            // 추가 정보를 입력하는 뷰로 이동
                            guard let emailVerificationVC = self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController else {
                                //아니면 종료
                                return
                            }
                            emailVerificationVC.type = type
                            emailVerificationVC.email = id
                            emailVerificationVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                            emailVerificationVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                            self.present(emailVerificationVC, animated: true, completion: nil)
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
}
