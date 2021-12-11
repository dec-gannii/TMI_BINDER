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
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfoilo").document("portfoilo").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let eduHistory = data?["eduHistory"] as? String ?? ""
                self.eduHistoryTF.text = eduHistory
                let classMethod = data?["classMethod"] as? String ?? ""
                self.classMetTF.text = classMethod
                let extraExprience = data?["extraExprience"] as? String ?? ""
                self.extraExpTF.text = extraExprience
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfoilo").document("portfoilo").setData([
            "eduHistory": eduHistoryTF.text ?? "None",
            "classMethod": classMetTF.text ?? "None",
            "extraExprience": extraExpTF.text ?? "None"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        
        let portfoiloVC = self.storyboard?.instantiateViewController(withIdentifier: "ProtfolioViewController")
        portfoiloVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        portfoiloVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        portfoiloVC?.isEditing = true
        self.present(portfoiloVC!, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
