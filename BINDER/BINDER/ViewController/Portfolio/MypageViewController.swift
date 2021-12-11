//
//  MypageViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import FirebaseFirestore
import Firebase

class MyPageViewController: UIViewController {
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBOutlet weak var portfoiolBtn: UIButton!
    @IBOutlet weak var openPortfolioSwitch: UISwitch!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        openPortfolioSwitch.onTintColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
        getUserInfo()
        viewDecorating()
    }
    
    func getUserInfo(){
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        if (docRef != nil){
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let name = data?["Name"] as? String ?? ""
                    self.nameLabel.text = name
                    
                   var role = data?["Type"] as? String ?? ""
                   if role == "teacher"{
                        role = "선생님"
                    }else if role == "student"{
                        role = "학생"
                    }
                    self.roleLabel.text = role
                    
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
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
