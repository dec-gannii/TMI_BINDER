//
//  ParentSettingViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import Firebase
import Kingfisher

class ParentMyPageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var childInfoBackgroundView: UIView!
    @IBOutlet weak var childPhoneNumberLabel: UILabel!
    
    
    @IBAction func DeleteChildInfoBtnClicked(_ sender: Any) {
    }
    
    @IBAction func LogoutBtnClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
        
        if Auth.auth().currentUser != nil {
            // Show logout page
            let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
            signinVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            signinVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(signinVC!, animated: true, completion: nil)
        } else {
            // Show login page
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else {
                //아니면 종료
                return
            }
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.isLogouted = true
            
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func GoSettingPageBtnClicked(_ sender: Any) {
        guard let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else {
            //아니면 종료
            return
        }
        settingVC.modalTransitionStyle = .crossDissolve
        settingVC.modalPresentationStyle = .fullScreen
        
        self.present(settingVC, animated: true, completion: nil)
    }
    
    func getUserInfo() {
        let db = Firestore.firestore()
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                        let name = document.data()["name"] as? String ?? ""
                        self.nameLabel.text = name
                        let url = URL(string: profile)!
                        self.profileImageView.kf.setImage(with: url)
                    }
                }
            }
        }
    }
    
}
