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
    
    // 비밀번호가 맞는지 확인하기 위해 비밀번호를 확인하는 메소드
    func getPW() {
        // 데이터베이스 경로
        var docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.currentPW = data?["Password"] as? String ?? ""
            } else {
                docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        self.currentPW = data?["Password"] as? String ?? ""
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OKBtnClicked(_ sender: Any) {
        // 만약 현재 저장되어 있는 비밀번호와 입력한 비밀번호가 동일하면
        if (currentPW == pwTextField.text) {
            // 정보 수정 화면으로 이동
            guard let editInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "EditInfoViewController") as? EditInfoViewController else { return }
            
            editInfoVC.modalPresentationStyle = .fullScreen
            editInfoVC.modalTransitionStyle = .crossDissolve
            
            self.present(editInfoVC, animated: true, completion: nil)
            errorLabel.isHidden = true
        } else {
            // 만약 현재 저장되어 있는 비밀번호와 입력한 비밀번호가 동일하지 않으면 오류 발생 Label 숨김 해제
            errorLabel.text = "현재 비밀번호가 올바르지 않습니다!"
            errorLabel.isHidden = false
        }
    }
}
