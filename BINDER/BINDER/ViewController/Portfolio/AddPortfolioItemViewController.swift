//
//  AddPortfolioItemViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/22.
//

import UIKit
import Kingfisher
import SwiftUI

class AddPortfolioItemViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var manageBtn: UIButton!
    @IBOutlet weak var memoBtn: UIButton!
    
    var btnDesign = ButtonDesign()
    var viewDesign = ViewDesign()
    var functionShare = FunctionShare()
    var myPageDB = MyPageDBFunctions()
    
    func setUI() {
        var textfields = [UITextField]()
        textfields = [self.titleTextField]
        
        functionShare.textFieldPaddingSetting(textfields)
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        contentTextView.textContainerInset = viewDesign.EdgeInsets
        
        contactBtn.clipsToBounds = true
        contactBtn.layer.cornerRadius = btnDesign.cornerRadius
        timeBtn.clipsToBounds = true
        timeBtn.layer.cornerRadius = btnDesign.cornerRadius
        manageBtn.clipsToBounds = true
        manageBtn.layer.cornerRadius = btnDesign.cornerRadius
        memoBtn.clipsToBounds = true
        memoBtn.layer.cornerRadius = btnDesign.cornerRadius
        
        contactBtn.titleLabel?.textColor = UIColor(rgb: 0x0168FF)
        timeBtn.titleLabel?.textColor = UIColor(rgb: 0xC2C2C2)
        manageBtn.titleLabel?.textColor = UIColor(rgb: 0xC2C2C2)
        memoBtn.titleLabel?.textColor = UIColor(rgb: 0xC2C2C2)
        
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
        
        self.titleTextField.text = "연락 수단"
        self.contactBtn.isSelected = true
        contactBtn.titleLabel?.textColor = UIColor(rgb: 0x2D68F6)
        contactBtn.backgroundColor = UIColor(rgb: 0xCDE7FC)
        
        // 키보드 띄우기
        titleTextField.becomeFirstResponder()
    }
    
    func placeholderSetting() {
        contentTextView.delegate = self // 유저가 선언한 outlet
        if contentTextView.text.isEmpty {
            if (contactBtn.isSelected) {
                contentTextView.text = StringUtils.contactPlaceHolder.rawValue
            } else if (manageBtn.isSelected) {
                contentTextView.text = StringUtils.managePlaceHolder.rawValue
            } else if (timeBtn.isSelected) {
                contentTextView.text = StringUtils.timePlaceHolder.rawValue
            } else if (memoBtn.isSelected) {
                contentTextView.text = StringUtils.memoPlaceHolder.rawValue
            }
            contentTextView.textColor = UIColor.lightGray
        } else {
            contentTextView.textColor = UIColor.black
        }
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
        if contentTextView.text.isEmpty {
            if (contactBtn.isSelected) {
                contentTextView.text = StringUtils.contactPlaceHolder.rawValue
            } else if (manageBtn.isSelected) {
                contentTextView.text = StringUtils.managePlaceHolder.rawValue
            } else if (timeBtn.isSelected) {
                contentTextView.text = StringUtils.timePlaceHolder.rawValue
            } else if (memoBtn.isSelected) {
                contentTextView.text = StringUtils.memoPlaceHolder.rawValue
            }
            contentTextView.textColor = UIColor.lightGray
        } else {
            contentTextView.textColor = UIColor.black
        }
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OkButtonClicked(_ sender: Any) {
        // 설정된 title 내용에 따라서 저장할 db 경로 이름 설정
        if let data = titleTextField.text, let content = contentTextView.text {
            var title = "contact"
            if (data == contactBtn.titleLabel!.text) {
                title = "contact"
            } else if (data == timeBtn.titleLabel!.text) {
                title = "time"
            } else if (data == manageBtn.titleLabel!.text) {
                title = "manage"
            } else if (data == memoBtn.titleLabel!.text) {
                title = "memo"
            }
            myPageDB.AddPortfolioFactors(title: title, content: content)
            dismiss(animated: true, completion: nil)
        } else {
            print("Document does not exist")
        }
    }
    
    @IBAction func TitleButtonClicked(_ sender: UIButton) {
        // 선택한 버튼의 타이틀 레이블 텍스트와 동일하게 titletextfield 글씨 설정
        self.titleTextField.text = (sender as AnyObject).titleLabel?.text
        sender.titleLabel?.textColor = UIColor(rgb: 0x2D68F6)
        sender.backgroundColor = UIColor(rgb: 0xCDE7FC)
        sender.isSelected = true
        
        if (sender != contactBtn) {
            contactBtn.titleLabel?.textColor = UIColor(rgb: 0xC2C2C2)
            contactBtn.backgroundColor = UIColor(rgb: 0xF5F5F5)
            contactBtn.isSelected = false
        }
        if (sender != timeBtn) {
            timeBtn.titleLabel?.textColor = UIColor(rgb: 0xC2C2C2)
            timeBtn.backgroundColor = UIColor(rgb: 0xF5F5F5)
            timeBtn.isSelected = false
        }
        if (sender != manageBtn) {
            manageBtn.titleLabel?.textColor = UIColor(rgb: 0xC2C2C2)
            manageBtn.backgroundColor = UIColor(rgb: 0xF5F5F5)
            manageBtn.isSelected = false
        }
        if (sender != memoBtn) {
            memoBtn.titleLabel?.textColor = UIColor(rgb: 0xC2C2C2)
            memoBtn.backgroundColor = UIColor(rgb: 0xF5F5F5)
            memoBtn.isSelected = false
        }
    }
}
