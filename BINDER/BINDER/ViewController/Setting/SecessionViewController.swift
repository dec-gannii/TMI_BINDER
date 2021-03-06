//
//  secessionViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/19.
//
// 서비스 탈퇴 화면

import UIKit
import Firebase

public class SecessionViewController: UIViewController {
    var btnDesign = ButtonDesign()
    var settingDB = SettingDBFunctions()
    @IBOutlet weak var secessionBtn: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        secessionBtn.clipsToBounds = true
        secessionBtn.layer.cornerRadius = btnDesign.cornerRadius
    }
    
    // 뒤로가기 버튼 클릭 시 수행되는 메소드
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 탈퇴하기 버튼 클릭 시 수행되는 메소드
    @IBAction func SecessionBtnClicked(_ sender: Any) {
        let user = Auth.auth().currentUser // 사용자 정보 가져오기
        
        user?.delete { error in
            if let error = error {
                // An error happened.
                print("delete user error : \(error)")
            } else {
                // Account deleted.
                // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
                self.settingDB.Secession(self: self)
            }
            
            // 로그인 화면(첫화면)으로 다시 이동
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}
