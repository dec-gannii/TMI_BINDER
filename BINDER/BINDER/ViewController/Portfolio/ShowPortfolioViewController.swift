//
//  ShowPortfolioViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/11.
//

import UIKit
import Firebase

// 포트폴리오 조회 뷰 컨트롤러
public class ShowPortfolioViewController: UIViewController {
    
    let db = Firestore.firestore()
    var btnDesign = ButtonDesign()
    var functionShare = FunctionShare()
    
    @IBOutlet weak var teacherEmailTextField: UITextField!
    @IBOutlet weak var showBtn: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var textfields = [UITextField]()
        textfields = [self.teacherEmailTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        /// 키보드 띄우기
        teacherEmailTextField.becomeFirstResponder()
        
        showBtn.clipsToBounds = true
        showBtn.layer.cornerRadius = btnDesign.cornerbtnRadius
    }
    
    // 포트폴리오 조회 버튼 클릭 시 실행되는 메소드
    @IBAction func ShowProtfolioBtn(_ sender: Any) {
        ShowPortfolio(self: self)
    }
    
    // x 버튼 클릭 시 실행되는 메소드
    @IBAction func xBtnClicked(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
