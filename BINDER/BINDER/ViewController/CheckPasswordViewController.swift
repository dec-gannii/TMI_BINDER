//
//  CheckPasswordViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/09.
//

import UIKit
import Firebase

class CheckPasswordViewController: UIViewController {
    
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var pwTextField: UITextField!
    var currentPW = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPW()
    }
    
    func getPW() {
        // 데이터베이스 경로
        let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.currentPW = data?["Password"] as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OKBtnClicked(_ sender: Any) {
        if (currentPW == pwTextField.text) {
            print("right PW")
            errorLabel.isHidden = true
        } else {
            errorLabel.text = "현재 비밀번호가 올바르지 않습니다!"
            errorLabel.isHidden = false
        }
    }
    
}

