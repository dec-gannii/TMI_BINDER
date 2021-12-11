//
//  ShowPortfolioViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/11.
//

import UIKit

import Firebase

class ShowPortfolioViewController: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var teacherEmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func ShowProtfolioBtn(_ sender: Any) {
        self.db.collection("teacher").whereField("Email", isEqualTo: teacherEmailTextField.text).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    let alert = UIAlertController(title: "탐색 오류", message: "유효하지 않은 선생님의 이메일입니다!", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    return
                }
                
                guard let portfolioVC = self.storyboard?.instantiateViewController(withIdentifier: "PortfolioViewController") as? PortfolioViewController else { return }
                portfolioVC.isShowMode = true
                portfolioVC.showModeEmail = self.teacherEmailTextField.text!
                self.present(portfolioVC, animated: true, completion: nil)
                
            }
            
            /// 변수 다시 공백으로 바꾸기
            self.teacherEmailTextField.text = ""
        }
    }
    
    @IBAction func xBtnClicked(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
