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
import CryptoKit

// 로그인 뷰 컨트롤러
class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var pwAlertLabel: UILabel!
    @IBOutlet weak var googleLogInBtn: GIDSignInButton!
    
    var isLogouted = true
    var email = ""
    var name = ""
    fileprivate var currentNonce: String?
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    let authorizationAppleIDButton = ASAuthorizationAppleIDButton()
    
    // MARK: - Selectors
    @objc private func handleAuthorizationAppleIDButton(_ sender: ASAuthorizationAppleIDButton) {
        startSignInWithAppleFlow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationAppleIDButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButton(_:)), for: .touchUpInside)
        
        view.addSubview(authorizationAppleIDButton)
        authorizationAppleIDButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.authorizationAppleIDButton.topAnchor.constraint(equalTo: self.googleLogInBtn.bottomAnchor
                                                                 , constant: 10),
            self.authorizationAppleIDButton.leftAnchor.constraint(equalTo: self.view.leftAnchor
                                                                  , constant: 40),
            self.authorizationAppleIDButton.rightAnchor.constraint(equalTo: self.view.rightAnchor
                                                                   , constant: -40),
            self.authorizationAppleIDButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        if (isLogouted == false) {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn() // 자동로그인
        }
        emailAlertLabel.isHidden = true
        pwAlertLabel.isHidden = true
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func LogInBtnClicked(_ sender: Any) {
        self.pwAlertLabel.isHidden = true
        self.emailAlertLabel.isHidden = true
        
        guard let email = emailTextField.text, let password = pwTextField.text else { return }
        
        // 로그인 수행 시, 에러 발생하면 띄울 alert
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as? NSError {
                switch AuthErrorCode(rawValue: error.code) {
                case .userDisabled:
                    let alert = UIAlertController(title: "로그인 실패", message: StringUtils.emailValidationAlert.rawValue, preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                case .wrongPassword:
                    self.emailAlertLabel.isHidden = true
                    self.pwAlertLabel.isHidden = false
                    self.pwAlertLabel.text = StringUtils.wrongPassword.rawValue
                    break
                case .emailAlreadyInUse:
                    Auth.auth().signIn(withEmail: email, password: password)
                    break
                default:
                    let alert = UIAlertController(title: "로그인 실패", message: StringUtils.loginFail.rawValue, preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    break
                }
            } else {
                // 별 오류 없으면 로그인 되어서 홈 뷰 컨트롤러 띄우기
                self.db.collection("parent").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            // 사용할 것들 가져와서 지역 변수로 저장
                            let type = document.data()["type"] as? String ?? ""
                            if (type == "parent") {
                                guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                                tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                self.present(tb, animated: true, completion: nil)
                            }
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
    }
    
    @IBAction func googleLogInBtnClicked(_ sender: Any) {
    }
    
    @IBAction func ResetPasswordBtnClicked(_ sender: Any) {
        guard let resetpwVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController else { return }
        resetpwVC.modalPresentationStyle = .pageSheet
        resetpwVC.modalTransitionStyle = .coverVertical
        self.present(resetpwVC, animated: true, completion: nil)
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

// MARK: - Google Login Extension
extension LogInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("signIn error: \(error.localizedDescription)")
            return
        } else {
            print("user email: \(user.profile.email ?? "no email")")
        }
        
        guard let auth = user.authentication else { return }
        let googleCredential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken) // 파이어베이스 로그인
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
}

@available(iOS 13.0, *)
extension LogInViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                if (error != nil) {
                    print("ERROR : \(error)")
                    return
                } else {
                    if ((AuthErrorCode.credentialAlreadyInUse.rawValue) != 0) {
                        // 로그인 화면(첫화면)으로 다시 이동
                        let alert = UIAlertController(title: "로그인 실패", message: StringUtils.emailExistAlert.rawValue, preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
                        alert.addAction(okAction)
                        self!.present(alert, animated: false, completion: nil)
                        
                        guard let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
                        loginVC.modalPresentationStyle = .fullScreen
                        loginVC.modalTransitionStyle = .crossDissolve
                        
                        self!.present(loginVC, animated: true, completion: nil)
                    } else {
                        // type select 화면으로 이동
                        guard let typeSelectVC = self?.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController") as? TypeSelectViewController else { return }
                        typeSelectVC.modalPresentationStyle = .fullScreen
                        typeSelectVC.modalTransitionStyle = .crossDissolve
                        
                        self!.present(typeSelectVC, animated: true, completion: nil)
                    }
                }
                //                    print ("email : \(self?.email)")
                //                    self!.db.collection("teacher").whereField("email", isEqualTo: self?.email).getDocuments() { (querySnapshot, err) in
                //                        if let err = err {
                //                            print("Error getting documents: \(err)")
                //                        } else {
                //                            for document in querySnapshot!.documents {
                //                                print("\(document.documentID) => \(document.data())")
                //                                // 로그인 화면(첫화면)으로 다시 이동
                //                                guard let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
                //                                loginVC.modalPresentationStyle = .fullScreen
                //                                loginVC.modalTransitionStyle = .crossDissolve
                //
                //                                self!.present(loginVC, animated: true, completion: nil)
                //                            }
                //                            self!.db.collection("student").whereField("email", isEqualTo: self?.email).getDocuments() { (querySnapshot, err) in
                //                                if let err = err {
                //                                    print("Error getting documents: \(err)")
                //                                } else {
                //                                    for document in querySnapshot!.documents {
                //                                        print("\(document.documentID) => \(document.data())")
                //                                        // 로그인 화면(첫화면)으로 다시 이동
                //                                        guard let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
                //                                        loginVC.modalPresentationStyle = .fullScreen
                //                                        loginVC.modalTransitionStyle = .crossDissolve
                //
                //                                        self!.present(loginVC, animated: true, completion: nil)
                //                                    }
                //                                    self!.db.collection("parent").whereField("email", isEqualTo: self?.email).getDocuments() { (querySnapshot, err) in
                //                                        if let err = err {
                //                                            print("Error getting documents: \(err)")
                //                                        } else {
                //                                            for document in querySnapshot!.documents {
                //                                                print("\(document.documentID) => \(document.data())")
                //                                                // 로그인 화면(첫화면)으로 다시 이동
                //                                                guard let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
                //                                                loginVC.modalPresentationStyle = .fullScreen
                //                                                loginVC.modalTransitionStyle = .crossDissolve
                //
                //                                                self!.present(loginVC, animated: true, completion: nil)
                //                                            }
                //                                        }
                //                                    }
                //                                }
                //                            }
                //                        }
                //                    }
                //                }
                //            }
                //        }
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) { // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    // fierbase iOS 로그인 가이드
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if length == 0 { return }
                if random < charset.count { result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        self.email = "\(request.requestedScopes![1])"
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { return String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
