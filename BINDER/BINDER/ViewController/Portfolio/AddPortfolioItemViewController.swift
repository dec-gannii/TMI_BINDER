//
//  AddPortfolioItemViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/22.
//

import UIKit
import Firebase
import Kingfisher

class AddPortfolioItemViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var manageBtn: UIButton!
    
    let db = Firestore.firestore()
    var btnDesign = ButtonDesign()
    var viewDesign = ViewDesign()
    
    func setUI() {
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        contentTextView.textContainerInset = viewDesign.EdgeInsets
        
        contactBtn.clipsToBounds = true
        contactBtn.layer.cornerRadius = btnDesign.cornerRadius
        timeBtn.clipsToBounds = true
        timeBtn.layer.cornerRadius = btnDesign.cornerRadius
        manageBtn.clipsToBounds = true
        manageBtn.layer.cornerRadius = btnDesign.cornerRadius
        
        // textview 테두리 설정
        self.contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentTextView.layer.borderWidth = viewDesign.borderWidth
        
        // cornerRadius 지정
        contentTextView.clipsToBounds = true
        contentTextView.layer.cornerRadius = btnDesign.cornerRadius
        
        // placeholder 설정
        placeholderSetting()
        textViewDidBeginEditing(self.contentTextView)
        textViewDidEndEditing(self.contentTextView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        // 키보드 띄우기
        titleTextField.becomeFirstResponder()
    }
    
    func placeholderSetting() {
        contentTextView.delegate = self // 유저가 선언한 outlet
        contentTextView.text = "추가할 내용을 입력해주세요."
        contentTextView.textColor = UIColor.lightGray
    }
    
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "추가할 내용을 입력해주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OkButtonClicked(_ sender: Any) {
        // 설정된 title 내용에 따라서 저장할 db 경로 이름 설정
        if let data = titleTextField.text, let content = contentTextView.text {
            var title = ""
            if (data == contactBtn.titleLabel!.text) {
                title = "contact"
            } else if (data == timeBtn.titleLabel!.text) {
                title = "time"
            } else if (data == manageBtn.titleLabel!.text) {
                title = "manage"
            }
            
            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                "\(title)": content
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            dismiss(animated: true, completion: nil)
        } else {
            print("Document does not exist")
        }
    }
    
    @IBAction func TitleButtonClicked(_ sender: Any) {
        // 선택한 버튼의 타이틀 레이블 텍스트와 동일하게 titletextfield 글씨 설정
        self.titleTextField.text = (sender as AnyObject).titleLabel?.text
    }
}
