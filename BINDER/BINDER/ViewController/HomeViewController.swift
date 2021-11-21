//
//  HomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase
import GoogleSignIn

class HomeViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Auth.auth().currentUser?.email != nil) {
            stateLabel.text = "로그인 성공! \n" + (Auth.auth().currentUser?.email)! + "님 환영합니다!"
        } else {
            stateLabel.text = "로그인 실패인 거 같은데요?"
        }
    }
    
    @IBAction func LogOutBtnClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
        
        if Auth.auth().currentUser != nil {
            // Show logout page
            let vcName = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
            vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(vcName!, animated: true, completion: nil)
        } else {
            // Show login page
            let vcName = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
            vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(vcName!, animated: true, completion: nil)
        }
    }
    
}



