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
    @IBOutlet weak var extraExpTF: UITextField!
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    var edu = ""
    var classMethod = ""
    var extra = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.eduHistoryTF.text = "비공개 설정 상태입니다."
                    self.classMetTF.text = "비공개 설정 상태입니다."
                    self.extraExpTF.text = "비공개 설정 상태입니다."
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        
//        self.db.collection("teacher").whereField("Email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print(">>>>> document 에러 : \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    self.teacherName.text = document.data()["Name"] as? String ?? ""
//                    self.teacherEmail.text = document.data()["Email"] as? String ?? ""
//                }
//            }
//        }
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let email = data?["Email"] as? String ?? ""
                
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
            "extraExprience": extraExpTF.text ?? "None"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        
        let portfolioVC = self.storyboard?.instantiateViewController(withIdentifier: "PortfolioViewController")
        
        portfolioVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        portfolioVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        portfolioVC?.isEditing = true
        
        self.present(portfolioVC!, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
