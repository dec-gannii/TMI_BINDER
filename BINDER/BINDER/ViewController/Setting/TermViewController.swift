//
//  TermViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/10.
//
// 이용 약관 화면

import UIKit

class TermViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 뒤로가기 버튼 클릭 시 수행되는 메소드
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
