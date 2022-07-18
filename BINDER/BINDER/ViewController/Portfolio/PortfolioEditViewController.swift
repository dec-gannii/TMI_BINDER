//
//  PortfolioEditViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/10.
//

import UIKit
import Firebase

public class PortfolioEditViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var eduHistoryTV: UITextView!
    @IBOutlet weak var classMetTV: UITextView!
    @IBOutlet weak var extraExpTV: UITextView!
    @IBOutlet weak var timeTV: UITextView!
    @IBOutlet weak var contactTV: UITextView!
    @IBOutlet weak var manageTV: UITextView!
    @IBOutlet weak var evaluationTV: UITextView!
    @IBOutlet weak var memoTV: UITextView!
    
    var ref: DatabaseReference!
    
    var edu = ""
    var classMethod = ""
    var extra = ""
    var showPortfolio = "On"
    
    var viewDesign = ViewDesign()
    var btnDesign = ButtonDesign()
    var myPageDB = MyPageDBFunctions()
    var functionShare = FunctionShare()
    
    func setTextViewUI() {
        // Border setting
        functionShare.setTextUI(textView: self.eduHistoryTV, design: viewDesign, btnDesign: btnDesign)
        functionShare.setTextUI(textView: self.classMetTV, design: viewDesign, btnDesign: btnDesign)
        functionShare.setTextUI(textView: self.extraExpTV, design: viewDesign, btnDesign: btnDesign)
        functionShare.setTextUI(textView: self.contactTV, design: viewDesign, btnDesign: btnDesign)
        functionShare.setTextUI(textView: self.timeTV, design: viewDesign, btnDesign: btnDesign)
        functionShare.setTextUI(textView: self.manageTV, design: viewDesign, btnDesign: btnDesign)
        functionShare.setTextUI(textView: self.evaluationTV, design: viewDesign, btnDesign: btnDesign)
        functionShare.setTextUI(textView: self.memoTV, design: viewDesign, btnDesign: btnDesign)
    }
    
    func placeholderSetting(_ textView: UITextView) {
        textView.delegate = self // 유저가 선언한 outlet
        if (textView.text.isEmpty) {
            if (textView == self.eduHistoryTV) {
                textView.text = StringUtils.eduHistoryPlaceHolder.rawValue
            } else if (textView == self.classMetTV) {
                textView.text = StringUtils.classMethodPlaceHolder.rawValue
            } else if (textView == self.extraExpTV) {
                textView.text = StringUtils.extraExperiencePlaceHolder.rawValue
            } else if (textView == self.timeTV) {
                textView.text = StringUtils.timePlaceHolder.rawValue
            } else if (textView == self.contactTV) {
                textView.text = StringUtils.contactPlaceHolder.rawValue
            } else if (textView == self.manageTV) {
                textView.text = StringUtils.managePlaceHolder.rawValue
            } else if (textView == self.memoTV) {
                textView.text = StringUtils.memoPlaceHolder.rawValue
            }
            textView.textColor = UIColor.lightGray
        } else {
            textView.textColor = UIColor.black
        }
    }
    
    // TextView Place Holder
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // TextView Place Holder
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if (textView == self.eduHistoryTV) {
                textView.text = StringUtils.eduHistoryPlaceHolder.rawValue
            } else if (textView == self.classMetTV) {
                textView.text = StringUtils.classMethodPlaceHolder.rawValue
            } else if (textView == self.extraExpTV) {
                textView.text = StringUtils.extraExperiencePlaceHolder.rawValue
            } else if (textView == self.timeTV) {
                textView.text = StringUtils.timePlaceHolder.rawValue
            } else if (textView == self.contactTV) {
                textView.text = StringUtils.contactPlaceHolder.rawValue
            } else if (textView == self.manageTV) {
                textView.text = StringUtils.managePlaceHolder.rawValue
            } else if (textView == self.memoTV) {
                textView.text = StringUtils.memoPlaceHolder.rawValue
            }
            textView.textColor = UIColor.lightGray
        } else {
            textView.textColor = UIColor.black
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setTextViewUI()
        myPageDB.GetPortfolioPlots(self: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        /// 키보드 올라올 때 화면 쉽게 이동할 수 있도록 해주는 것, 키보드 높이만큼 padding
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 키보드 올라올때 처리
    /// - Parameter notification: 노티피케이션
    @objc func keyboardWillShow(notification:NSNotification) {
        if (self.timeTV.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.timeTV.frame.height)
        } else if (self.contactTV.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.timeTV.frame.height + self.contactTV.frame.height)
        } else if (self.manageTV.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.contactTV.frame.height + self.manageTV.frame.height)
        } else if (self.manageTV.isFirstResponder == true) {
            self.view.frame.origin.y = -(self.manageTV.frame.height + self.memoTV.frame.height)
        }
    }
    
    /// 키보드 내려갈때 처리
    @objc func keyboardWillHide(notification:NSNotification) {
        self.view.frame.origin.y = 0 // Move view 150 points upward
    }
    
    @IBAction func editButton(_ sender: Any) {
        myPageDB.SaveEditedPlot(self: self)
        
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
