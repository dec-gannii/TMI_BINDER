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
        self.present(portfoiloVC!, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
