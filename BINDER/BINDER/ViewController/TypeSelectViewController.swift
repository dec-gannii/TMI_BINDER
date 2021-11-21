//
//  ViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase

class TypeSelectViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func SelectTeacherRole(_ sender: Any) {
        // 선생님 선택시 작동하는 함수 (우선은 회원가입 화면이 바로 나오게 설정해놨음)
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(vcName!, animated: true, completion: nil)
    }
    
    @IBAction func SelectStudentRole(_ sender: Any) {
        // 학생 선택시 작동하는 함수
    }
    
    @IBAction func SelectParentRole(_ sender: Any) {
        // 학부모 선택시 작동하는 함수
    }
    
    @IBAction func ShowPortfolio(_ sender: Any) {
        // 포트폴리오 보기 선택시 작동하는 함수
    }

}



