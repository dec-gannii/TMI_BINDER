//
//  ShowPortfolioViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/11.
//

import UIKit
import Firebase

// 포트폴리오 조회 뷰 컨트롤러
class ShowPortfolioViewController: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var teacherEmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 포트폴리오 조회 버튼 클릭 시 실행되는 메소드
    @IBAction func ShowProtfolioBtn(_ sender: Any) {
        // 입력된 이메일과 동일한 값을 가지는 이메일 필드가 있다면 수행
        self.db.collection("teacher").whereField("email", isEqualTo: teacherEmailTextField.text!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                // 도큐먼트 존재 안 하면 유효하지 않은 선생님 이메일이라고 alert 발생
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    let alert = UIAlertController(title: "탐색 오류", message: "유효하지 않은 선생님의 이메일입니다!", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated: false, completion: nil)
                    return
                }
                
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let email = document.data()["email"] as? String ?? ""
                    // 포트폴리오를 보여주는 화면 present
                    guard let portfolioVC = self.storyboard?.instantiateViewController(withIdentifier: "PortfolioTableViewController") as? PortfolioTableViewController else { return }
                    portfolioVC.isShowMode = true
                    portfolioVC.showModeEmail = email
                    self.present(portfolioVC, animated: true, completion: nil)
                }
            }
            /// 변수 다시 공백으로 바꾸기
            self.teacherEmailTextField.text = ""
        }
    }
    
    // x 버튼 클릭 시 실행되는 메소드
    @IBAction func xBtnClicked(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
