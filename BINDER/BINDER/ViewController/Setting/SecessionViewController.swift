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
    let db = Firestore.firestore()
    var btnDesign = ButtonDesign()
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
        Secession(self: self)
    }
}
