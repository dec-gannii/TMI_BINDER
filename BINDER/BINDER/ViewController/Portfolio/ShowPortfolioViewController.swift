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
    var btnDesign = ButtonDesign()
    
    @IBOutlet weak var teacherEmailTextField: UITextField!
    @IBOutlet weak var showBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 키보드 띄우기
        teacherEmailTextField.becomeFirstResponder()
        
        showBtn.clipsToBounds = true
        showBtn.layer.cornerRadius = btnDesign.cornerRadius
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
                    let alert = UIAlertController(title: "탐색 오류", message: StringUtils.tEmailNotExist.rawValue, preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "확인", style: .default) { (action) in }
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
