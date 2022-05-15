//
//  ViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase

// 선생님, 학생, 학부모 타입 선택 뷰 컨트롤러
class TypeSelectViewController: UIViewController {
    var isGoogleSignIn = false
    var name:String = ""
    var email: String = ""
    var isAppleLogIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 선생님 타입 선택 시 실행되는 메소드
    @IBAction func SelectTeacherRole(_ sender: Any) {
        // 선생님 선택시 작동하는 함수 (우선은 회원가입 화면이 바로 나오게 설정해놨음)
        guard let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController else {
            //아니면 종료
            return
        }
        signinVC.type = "teacher" // 타입 설정
        signinVC.isGoogleSignIn = self.isGoogleSignIn
        signinVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        signinVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        signinVC.isAppleSignIn = self.isAppleLogIn
        if (self.isAppleLogIn == true) {
            signinVC.name = name
            signinVC.email = email
        }
        //화면전환
        self.present(signinVC, animated: true)
    }
    
    // 학생 타입 선택 시 실행되는 메소드
    @IBAction func SelectStudentRole(_ sender: Any) {
//        // 학생 선택시 작동하는 함수
        guard let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController else {
            //아니면 종료
            return
        }
        signinVC.type = "student" // 타입 설정
        signinVC.isGoogleSignIn = self.isGoogleSignIn
        signinVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        signinVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        signinVC.isAppleSignIn = self.isAppleLogIn
        if (self.isAppleLogIn == true) {
            signinVC.name = name
            signinVC.email = email
        }
        //화면전환
        self.present(signinVC, animated: true)
    }
    
    // 학부모 타입 선택 시 실행되는 메소드
    @IBAction func SelectParentRole(_ sender: Any) {
        // 학부모 선택시 작동하는 함수
        guard let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController else {
            //아니면 종료
            return
        }
        signinVC.type = "parent" // 타입 설정
        signinVC.isGoogleSignIn = self.isGoogleSignIn
        signinVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        signinVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        signinVC.isAppleSignIn = self.isAppleLogIn
        if (self.isAppleLogIn == true) {
            signinVC.name = name
            signinVC.email = email
        }
        //화면전환
        self.present(signinVC, animated: true)
    }
    
    @IBAction func GoBackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}



