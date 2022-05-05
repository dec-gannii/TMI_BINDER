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
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    var edu = ""
    var classMethod = ""
    var extra = ""
    var showPortfolio = "On"
    
    var viewDesign = ViewDesign()
    var btnDesign = ButtonDesign()
    
    func setTextViewUI() {
        // Border setting
        self.eduHistoryTV.layer.borderWidth = viewDesign.borderWidth
        self.eduHistoryTV.layer.borderColor = viewDesign.borderColor
        self.classMetTV.layer.borderWidth = viewDesign.borderWidth
        self.classMetTV.layer.borderColor = viewDesign.borderColor
        self.extraExpTV.layer.borderWidth = viewDesign.borderWidth
        self.extraExpTV.layer.borderColor = viewDesign.borderColor
        self.timeTV.layer.borderWidth = viewDesign.borderWidth
        self.timeTV.layer.borderColor = viewDesign.borderColor
        self.contactTV.layer.borderWidth = viewDesign.borderWidth
        self.contactTV.layer.borderColor = viewDesign.borderColor
        self.manageTV.layer.borderWidth = viewDesign.borderWidth
        self.manageTV.layer.borderColor = viewDesign.borderColor
        self.evaluationTV.layer.borderWidth = viewDesign.borderWidth
        self.evaluationTV.layer.borderColor = viewDesign.borderColor
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        self.eduHistoryTV.textContainerInset = viewDesign.EdgeInsets
        self.classMetTV.textContainerInset = viewDesign.EdgeInsets
        self.extraExpTV.textContainerInset = viewDesign.EdgeInsets
        self.timeTV.textContainerInset = viewDesign.EdgeInsets
        self.manageTV.textContainerInset = viewDesign.EdgeInsets
        self.contactTV.textContainerInset = viewDesign.EdgeInsets
        self.evaluationTV.textContainerInset = viewDesign.EdgeInsets
        
        // cornerRadius 지정
        self.eduHistoryTV.clipsToBounds = true
        self.eduHistoryTV.layer.cornerRadius = btnDesign.cornerRadius
        self.classMetTV.clipsToBounds = true
        self.classMetTV.layer.cornerRadius = btnDesign.cornerRadius
        self.extraExpTV.clipsToBounds = true
        self.extraExpTV.layer.cornerRadius = btnDesign.cornerRadius
        self.timeTV.clipsToBounds = true
        self.timeTV.layer.cornerRadius = btnDesign.cornerRadius
        self.manageTV.clipsToBounds = true
        self.manageTV.layer.cornerRadius = btnDesign.cornerRadius
        self.contactTV.clipsToBounds = true
        self.contactTV.layer.cornerRadius = btnDesign.cornerRadius
        self.evaluationTV.clipsToBounds = true
        self.evaluationTV.layer.cornerRadius = btnDesign.cornerRadius
    }
    
    func placeholderSetting(_ textView: UITextView) {
        textView.delegate = self // 유저가 선언한 outlet
        textView.text = StringUtils.contentNotExist.rawValue
        textView.textColor = UIColor.lightGray
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
            textView.text = StringUtils.contentNotExist.rawValue
            textView.textColor = UIColor.lightGray
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setTextViewUI()
        GetPortfolioPlots(self: self)
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func editButton(_ sender: Any) {
        SaveEditedPlot(self: self)
        
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
