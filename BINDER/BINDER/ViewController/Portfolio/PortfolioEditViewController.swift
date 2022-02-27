//
//  PortfolioEditViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/10.
//

import UIKit
import Firebase

class PortfolioEditViewController: UIViewController {
    
    @IBOutlet weak var eduHistoryTF: UITextField!
    @IBOutlet weak var classMetTF: UITextField!
    @IBOutlet weak var extraExpTF: UITextView!
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    var edu = ""
    var classMethod = ""
    var extra = ""
    var showPortfolio = "On"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.extraExpTF.layer.borderWidth = 1.0
        self.extraExpTF.layer.borderColor = UIColor.systemGray6.cgColor
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let eduHistory = data?["eduHistory"] as? String ?? ""
                self.eduHistoryTF.text = eduHistory
                let classMethod = data?["classMethod"] as? String ?? ""
                self.classMetTF.text = classMethod
                let extraExprience = data?["extraExprience"] as? String ?? ""
                self.extraExpTF.text = extraExprience
                let showPortfolio = data?["portfolioShow"] as? String ?? ""
                if (showPortfolio == "Off") {
                    self.showPortfolio = "Off"
                } else {
                    self.showPortfolio = "On"
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func editButton(_ sender: Any) {
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let email = data?["email"] as? String ?? ""
                
                self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                    "portfolioEmail": email
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").setData([
            "eduHistory": eduHistoryTF.text ?? "None",
            "classMethod": classMetTF.text ?? "None",
            "extraExprience": extraExpTF.text ?? "None",
            "portfolioShow": self.showPortfolio
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
