//
//  LogInViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/21.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices

// 로그인 뷰 컨트롤러
class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var pwAlertLabel: UILabel!
    @IBOutlet weak var googleLogInBtn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //GIDSignIn.sharedInstance()?.restorePreviousSignIn() //자동로그인
        emailAlertLabel.isHidden = true
        pwAlertLabel.isHidden = true
    }
    
    @IBAction func LogInBtnClicked(_ sender: Any) {
        guard let email = emailTextField.text, let password = pwTextField.text else { return }
        
        // 로그인 수행 시, 에러 발생하면 띄울 alert
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as? NSError {
                switch AuthErrorCode(rawValue: error.code) {
                case .userDisabled:
                    // Error: The user account has been disabled by an administrator.
                    let alert = UIAlertController(title: "로그인 실패", message: "사용할 수 없는 사용자 계정입니다.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                case .wrongPassword:
                    // Error: The password is invalid or the user does not have a password.
                    self.emailAlertLabel.isHidden = true
                    self.pwAlertLabel.isHidden = false
                    self.pwAlertLabel.text = "비밀번호가 틀렸습니다!"
                    break
                default:
                    let alert = UIAlertController(title: "로그인 실패", message: "로그인에 실패하였습니다. 다시 시도해주세요.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                }
            } else {
                // 별 오류 없으면 로그인 되어서 홈 뷰 컨트롤러 띄우기
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
    
    @IBAction func googleLogInBtnClicked(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
        guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            //아니면 종료
            return
        }
        if (Auth.auth().currentUser?.isEmailVerified == true){
            homeVC.verified = true
        } else { homeVC.verified = false }
        //화면전환
        homeVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        homeVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(homeVC, animated: true)
    }
    
    // 회원가입 버튼 클릭 시 실행되는 메소드
    @IBAction func SignInBtnClicked(_ sender: Any) {
        let typeSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController")
        typeSelectVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        typeSelectVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(typeSelectVC!, animated: true, completion: nil)
    }
    
    
    @IBAction func ShowPortfolio(_ sender: Any) {
        // 포트폴리오 보기 선택시 작동하는 함수
    }
}

extension LogInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("sigIn error: \(error.localizedDescription)")
            return
        } else {
            print("user email: \(user.profile.email ?? "no email")")
        }
        guard let auth = user.authentication else { return }
        
        let googleCredential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        // 파이어베이스 로그인
        
        Auth.auth().signIn(with: googleCredential) { (authResult, error) in
            if let error = error {
                print("Firebase sign in error: \(error)")
                return
            }
            else {
                print("User is signed with Firebase&Google")
                self.performSegue(withIdentifier: "HomeViewController", sender: nil)
            }
        }
    }
}
