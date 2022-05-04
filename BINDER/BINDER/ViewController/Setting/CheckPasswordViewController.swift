//
//  CheckPasswordViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/09.
//
// 비밀번호 확인 화면

import UIKit
import Firebase
import FirebaseDatabase

class CheckPasswordViewController: UIViewController {
    
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var okBtn: UIButton!
    var currentPW = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPW() // 현재 비밀번호가 맞는지 확인하기 위해 호출
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = 10
    }
    
    // 비밀번호가 맞는지 확인하기 위해 비밀번호를 확인하는 메소드
    func getPW() {
        // 데이터베이스 경로
        var docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                self.currentPW = data?["password"] as? String ?? ""
            } else {
                // 먼저 설정한 선생님 정보의 uid의 경로가 없다면 학생 정보에서 재탐색
                docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                        self.currentPW = data?["password"] as? String ?? ""
                    } else {
                        docRef = self.db.collection("parent").document(Auth.auth().currentUser!.uid)
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                                self.currentPW = data?["password"] as? String ?? ""
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 뒤로 가기 버튼 클릭 시 실행되는 메소드
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 완료 버튼 클릭 시 실행되는 메소드
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
            errorLabel.text = StringUtils.wrongPassword.rawValue
            errorLabel.isHidden = false
        }
    }
}
