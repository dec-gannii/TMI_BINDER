//
//  PortfolioEditViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/10.
//

import UIKit
import Firebase

class PortfolioEditViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var eduHistoryTV: UITextView!
    @IBOutlet weak var classMetTV: UITextView!
    @IBOutlet weak var extraExpTV: UITextView!
    @IBOutlet weak var timeTV: UITextView!
    @IBOutlet weak var contactTV: UITextView!
    @IBOutlet weak var manageTV: UITextView!
    @IBOutlet weak var evaluationTV: UITextView!
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    var edu :String!
    var classMethod :String!
    var extra :String!
    var showPortfolio:String!
    
    var viewDesign = ViewDesign()
    var btnDesign = ButtonDesign()
    
    func _init(){
        edu = ""
        classMethod = ""
        extra = ""
        showPortfolio = "On"
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
            textView.text = StringUtils.contentNotExist.rawValue
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var textView:Array<UITextView> = [self.eduHistoryTV,self.classMetTV,self.extraExpTV,self.timeTV,self.manageTV,self.contactTV,self.evaluationTV]
        setTextViewUI(textList:textView,viewdesign: viewDesign,btndesign: btnDesign)
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let eduHistory = data?["eduHistory"] as? String ?? ""
                self.eduHistoryTV.text = eduHistory
                // placeholder 설정
                if (self.eduHistoryTV.text == "") {
                    placeholderSetting(self.eduHistoryTV)
                    self.textViewDidBeginEditing(self.eduHistoryTV)
                    self.textViewDidEndEditing(self.eduHistoryTV)
                }
                let classMethod = data?["classMethod"] as? String ?? ""
                self.classMetTV.text = classMethod
                // placeholder 설정
                if (self.classMetTV.text == "") {
                    placeholderSetting(self.classMetTV)
                    self.textViewDidBeginEditing(self.classMetTV)
                    self.textViewDidEndEditing(self.classMetTV)
                }
                let extraExprience = data?["extraExprience"] as? String ?? ""
                self.extraExpTV.text = extraExprience
                // placeholder 설정
                if (self.extraExpTV.text == "") {
                    placeholderSetting(self.extraExpTV)
                    self.textViewDidBeginEditing(self.extraExpTV)
                    self.textViewDidEndEditing(self.extraExpTV)
                }
                let manage = data?["manage"] as? String ?? ""
                self.manageTV.text = manage
                // placeholder 설정
                if (self.manageTV.text == "") {
                    placeholderSetting(self.manageTV)
                    self.textViewDidBeginEditing(self.manageTV)
                    self.textViewDidEndEditing(self.manageTV)
                }
                let contact = data?["contact"] as? String ?? ""
                self.contactTV.text = contact
                // placeholder 설정
                if (self.contactTV.text == "") {
                    placeholderSetting(self.contactTV)
                    self.textViewDidBeginEditing(self.contactTV)
                    self.textViewDidEndEditing(self.contactTV)
                }
                let time = data?["time"] as? String ?? ""
                self.timeTV.text = time
                // placeholder 설정
                if (self.timeTV.text == "") {
                    placeholderSetting(self.timeTV)
                    self.textViewDidBeginEditing(self.timeTV)
                    self.textViewDidEndEditing(self.timeTV)
                }
                self.evaluationTV.text = "선생님이 수정할 수 없습니다."
                self.evaluationTV.isEditable = false
                
                let showPortfolio = data?["portfolioShow"] as? String ?? ""
                if (showPortfolio == "Off") {
                    self.showPortfolio = "Off"
                } else {
                    self.showPortfolio = "On"
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func editButton(_ sender: Any) {
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let email = data?["email"] as? String ?? ""
                
                self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                    "portfolioEmail": email
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").setData([
            "eduHistory": eduHistoryTV.text ?? "",
            "classMethod": classMetTV.text ?? "",
            "extraExprience": extraExpTV.text ?? "",
            "portfolioShow": self.showPortfolio,
            "time": timeTV.text ?? "",
            "manage": manageTV.text ?? "",
            "contact": contactTV.text ?? ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        
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
