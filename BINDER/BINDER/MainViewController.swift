//
//  MainViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/15.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit

public class MainViewController : UIViewController {
    
    @IBOutlet weak var signUpByMailBtn: UIButton!
    @IBOutlet weak var googleLogInBtn: GIDSignInButton!
    
    // 변수 선언
    var isLogouted: Bool!
    var email:String!
    var name:String!
    var viewDesign = ViewDesign()
    var btnDesign = ButtonDesign()
    fileprivate var currentNonce: String?
    
    let authorizationAppleIDButton = ASAuthorizationAppleIDButton()
    
    /// sign in with apple
    @objc private func handleAuthorizationAppleIDButton(_ sender: ASAuthorizationAppleIDButton) {
        startSignInWithAppleFlow()
    }
    
    func _init(){
        isLogouted = true
        email = ""
        name = ""
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        authorizationAppleIDButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButton(_:)), for: .touchUpInside)
        
        view.addSubview(authorizationAppleIDButton)
        authorizationAppleIDButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.authorizationAppleIDButton.topAnchor.constraint(equalTo: self.googleLogInBtn.bottomAnchor
                                                                 , constant: 10),
            self.authorizationAppleIDButton.rightAnchor.constraint(equalTo: self.view.rightAnchor
                                                                   , constant: -24),
            self.authorizationAppleIDButton.leftAnchor.constraint(equalTo: self.view.leftAnchor
                                                                   , constant: 24),
            self.authorizationAppleIDButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // google log in button customize
        googleLogInBtn.style = .wide
        googleLogInBtn.layer.borderWidth = viewDesign.borderWidth
        googleLogInBtn.layer.borderColor = UIColor.clear.cgColor
        googleLogInBtn.layer.shadowOpacity = 0.0
        googleLogInBtn.clipsToBounds = true
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        if (isLogouted == false) {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn() // 자동로그인
        }
    }
    
    @IBAction func GoSignInByEmailBtnClicked(_ sender: Any) {
        
        let typeSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeSelectViewController")
        typeSelectVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        typeSelectVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(typeSelectVC!, animated: true, completion: nil)
    }
}

/// sign in with google (extension)
extension MainViewController: GIDSignInDelegate {
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("signIn error: \(error.localizedDescription)")
            return
        } else {
            print("user email: \(user.profile.email ?? "no email")")
        }
        
        guard let auth = user.authentication else { return }
        let googleCredential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken) // 파이어베이스 로그인
        GoogleLogIn(googleCredential: googleCredential, self: self)
    }
}

/// sign in with apple (extension)
@available(iOS 13.0, *)
extension MainViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
            
            let appleSignIndb = Firestore.firestore()
            AppleLogIn(credential: credential, self: self)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) { // Handle error.
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
    
    // background 에 앱이 내려가 있는 경우 사용중단 분기처리
    func applicationDidBecomeActive(_ application: UIApplication) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "001628.1f39bf3727b44f1f8a6615166ae3b718.0924") { (credentialState, error) in
            switch credentialState {
                
            case .revoked:
                // Apple ID 사용 중단 경우.
                // 로그아웃
                print("revoked")
                print("go to login")
            case .authorized:
                print("authorized")
                print("go to home")
            case .notFound:
                // 잘못된 useridentifier 로 credentialState 를 조회하거나 애플로그인 시스템에 문제가 있을 때
                print("notFound")
                print("go to login")
            @unknown default:
                print("default")
                print("go to login")
            }
        }
    }
    
    // 앱을 실행할 경우 사용중단 분기처리
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "001628.1f39bf3727b44f1f8a6615166ae3b718.0924") { (credentialState, error) in
            switch credentialState {
                
            case .revoked:
                // Apple ID 사용 중단 경우.
                // 로그아웃
                print("revoked")
                print("go to login")
            case .authorized:
                print("authorized")
                print("go to home")
            case .notFound:
                // 잘못된 useridentifier 로 credentialState 를 조회하거나 애플로그인 시스템에 문제가 있을 때
                print("notFound")
                print("go to login")
            @unknown default:
                print("default")
                print("go to login")
            }
        }
        
        return true
    }
}
