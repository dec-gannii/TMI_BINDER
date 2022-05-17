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

public class CheckPasswordViewController: UIViewController {
    
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var okBtn: UIButton!
    var currentPW = ""
    var functionShare = FunctionShare()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        /// 키보드 띄우기
        self.pwTextField.becomeFirstResponder()
        
        var textfields = [UITextField]()
        textfields = [self.pwTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        GetPW() // 현재 비밀번호가 맞는지 확인하기 위해 호출
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = 10
    }
    
    // 뒤로 가기 버튼 클릭 시 실행되는 메소드
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 완료 버튼 클릭 시 실행되는 메소드
    @IBAction func OKBtnClicked(_ sender: Any) {
        // 만약 현재 저장되어 있는 비밀번호와 입력한 비밀번호가 동일하면
        if (sharedCurrentPW == pwTextField.text) {
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
