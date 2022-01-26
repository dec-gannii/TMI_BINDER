//
//  MypageViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import FirebaseFirestore
import Firebase
import Kingfisher

class MyPageViewController: BaseVC {
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    
    @IBOutlet weak var portfoiolBtn: UIButton!
    @IBOutlet weak var openPortfolioSwitch: UISwitch!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        openPortfolioSwitch.onTintColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
        getUserInfo()
        getPortfolioShow()
        viewDecorating()
    }
    
    func getUserInfo(){
        LoginRepository.shared.doLogin {
            self.nameLabel.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
            self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
            
            
            let url = URL(string: LoginRepository.shared.teacherItem!.profile)
            
            // photoURL 있는 경우
//            let url = Auth.auth().currentUser?.photoURL
            self.imageView.kf.setImage(with: url)
            self.imageView.makeCircle()
            
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
    }
    
    func getPortfolioShow() {
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let isShowOK = data?["portfolioShow"] as? String ?? ""
                if (isShowOK == "On") {
                    self.openPortfolioSwitch.setOn(true, animated: true)
                } else {
                    self.openPortfolioSwitch.setOn(false, animated: true)
                }
                
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func ShowProtfolioBtnClicked(_ sender: Any) {
        if (self.openPortfolioSwitch.isOn) {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                "portfolioShow": "On"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
        } else {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                "portfolioShow": "Off"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
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
            let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
            signinVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            signinVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(signinVC!, animated: true, completion: nil)
        } else {
            // Show login page
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
            loginVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            loginVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(loginVC!, animated: true, completion: nil)
        }
    }
    
    func viewDecorating(){
        portfoiolBtn.layer.cornerRadius = 20
        pageView.layer.cornerRadius = 30
        
        pageView.layer.shadowColor = UIColor.black.cgColor
        pageView.layer.masksToBounds = false
        pageView.layer.shadowOffset = CGSize(width: 2, height: 3)
        pageView.layer.shadowRadius = 5
        pageView.layer.shadowOpacity = 0.3
    }
    
}

