//
//  ViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/14.
//

import UIKit
import FirebaseAuthUI
import FirebaseAuth
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FBSDKLoginKit

class ViewController: UIViewController, FUIAuthDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    
    let authUI = FUIAuth.defaultAuthUI()
    var handle:AuthStateDidChangeListenerHandle!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let currentUser = auth.currentUser {
                // 로그인이 되어있는 상태
                if let displayName = currentUser.displayName {
                    let mainView = self.storyboard!.instantiateViewController(withIdentifier: "mainViewController")
                    mainView.modalPresentationStyle = .fullScreen
                    self.present(mainView, animated: true, completion: nil)
                }
            } else {
                // 로그아웃이 되어있는 상태
                self.authUI!.delegate = self
                let providers: [FUIAuthProvider] = [
                    FUIEmailAuth(),
                    FUIGoogleAuth(),
                    FUIOAuth.appleAuthProvider()
                    
                ]
                self.authUI!.providers = providers
                
                let authViewController = self.authUI!.authViewController()
                authViewController.modalPresentationStyle = .fullScreen
                
                self.present(authViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print("sign in")
        print(authDataResult)
    }
    
    
    
    @IBAction func doSignOut(_ sender: UIButton) {
        try? authUI?.signOut()
    }
}

extension FUIAuthBaseViewController {
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = nil
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
