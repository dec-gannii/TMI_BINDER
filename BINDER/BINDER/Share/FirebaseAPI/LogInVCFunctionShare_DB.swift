//
//  LogInVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

struct LogInVCDBFunctions {
    func LogInAndShowHomeVC (email : String, password: String, self : LogInViewController) {
        // 별 오류 없으면 로그인 되어서 홈 뷰 컨트롤러 띄우기
        db.collection("parent").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
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
}
