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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // 키보드 띄우기
        titleTextField.becomeFirstResponder()
        
        self.contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentTextView.layer.borderWidth = 0.3
        
        contentTextView.clipsToBounds = true
        contentTextView.layer.cornerRadius = 10
        
        placeholderSetting()
        textViewDidBeginEditing(self.contentTextView)
        textViewDidEndEditing(self.contentTextView)
    }
    
    func placeholderSetting() {
        contentTextView.delegate = self // txtvReview가 유저가 선언한 outlet
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
        if ((sender as AnyObject).tag == 0) {
            self.titleTextField.text = (sender as AnyObject).titleLabel?.text
        } else if ((sender as AnyObject).tag == 1) {
            self.titleTextField.text = (sender as AnyObject).titleLabel?.text
        } else if ((sender as AnyObject).tag == 2) {
            self.titleTextField.text = (sender as AnyObject).titleLabel?.text
        }
    }
}
