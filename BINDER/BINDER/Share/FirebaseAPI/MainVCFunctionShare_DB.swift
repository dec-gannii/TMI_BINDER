//
//  MainVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import UIKit

struct MainVCDBFunctions {
    func GoogleLogIn(googleCredential : AuthCredential, self : MainViewController) {
        Auth.auth().signIn(with: googleCredential) {
            (authResult, error) in if let error = error {
                print("Firebase sign in error: \(error)")
                return
            } else {
                db.collection("teacher").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let data = document.data()
                            let email = data["email"] as? String ?? ""
                            let password = data["password"] as? String ?? ""
                            
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
                        db.collection("student").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let data = document.data()
                                    let email = data["email"] as? String ?? ""
                                    let password = data["password"] as? String ?? ""
                                    
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
                                db.collection("parent").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            print("\(document.documentID) => \(document.data())")
                                            
                                            guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                                            tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                            self.present(tb, animated: true, completion: nil)
                                            
                                            return
                                        }
                                        // type select 화면으로 이동
                                        guard let typeSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController") as? TypeSelectViewController else { return }
                                        typeSelectVC.modalPresentationStyle = .fullScreen
                                        typeSelectVC.modalTransitionStyle = .crossDissolve
                                        typeSelectVC.name = Auth.auth().currentUser?.displayName ?? ""
                                        typeSelectVC.email = Auth.auth().currentUser?.email ?? ""
                                        typeSelectVC.isAppleLogIn = true
                                        
                                        self.present(typeSelectVC, animated: true, completion: nil)
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
    
    func AppleLogIn(credential : OAuthCredential, self : MainViewController) {
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if (error != nil) {
                return
            } else {
                db.collection("teacher").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let data = document.data()
                            let email = data["email"] as? String ?? ""
                            let password = data["password"] as? String ?? ""
                            
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
                        db.collection("student").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let data = document.data()
                                    let email = data["email"] as? String ?? ""
                                    let password = data["password"] as? String ?? ""
                                    
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
                                db.collection("parent").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments() { (querySnapshot, err) in
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
}

