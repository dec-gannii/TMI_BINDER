//
//  InsertClassInfoViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/30.
//

import UIKit
import Firebase

class InsertClassInfoViewController: UIViewController {
    @IBOutlet weak var studentEmail: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var countSelect: UIButton!
    @IBOutlet weak var creditDayTextField: UITextField!
    @IBOutlet weak var schedule: UIButton!
    @IBOutlet weak var isRepeat: UISwitch!
    
    var sEmail: String!
    var sName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentName.text = self.sName
        studentEmail.text = self.sEmail
    }
    
    @IBAction func SaveButtonClicked(_ sender: Any) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        var formatter_time = DateFormatter()
        formatter_time.dateFormat = "YYYY-MM-dd HH:mm"
        var current_time_string = formatter_time.string(from: Date())
        
        if (subjectTextField.text != "" && moneyTextField.text != "" && creditDayTextField.text != "") {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Class").document(sName + "(" + sEmail + ")").setData([
                "Subject": subjectTextField.text!,
                "Salary": moneyTextField.text!,
                "CreditDay": creditDayTextField.text!,
                "isRepeat": isRepeat.isOn,
                "ConnectedTime": current_time_string ])
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            print("done")
//            self.dismiss(animated: true, completion: nil)
        }
    }
}
