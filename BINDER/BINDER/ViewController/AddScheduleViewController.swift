//
//  AddScheduleViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/23.
//

import UIKit
import Firebase

class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scheduleTitle: UITextField!
    @IBOutlet weak var schedulePlace: UITextField!
    @IBOutlet weak var scheduleTime: UITextField!
    @IBOutlet weak var scheduleMemo: UITextView!
    var date: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateLabel.text = date
        self.scheduleMemo.layer.borderWidth = 1.0
        self.scheduleMemo.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    @IBAction func AddScheduleSubmitBtn(_ sender: Any) {
        if (scheduleTitle.text != "") {
            if ((scheduleTitle.text?.trimmingCharacters(in: .whitespaces)) != "") {
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                
                var formatter_time = DateFormatter()
                formatter_time.dateFormat = "YYYY-MM-dd HH:mm"
                var current_time_string = formatter_time.string(from: Date())
                
                db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(current_time_string).document(scheduleTitle.text!).setData(
                    ["Title": scheduleTitle.text!,
                    "Place": schedulePlace.text!,
                    "Time": date,
                    "Memo": scheduleMemo.text!,
                    "SavedTime": current_time_string]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                
//                db.collection("Schedule").document(Auth.auth().currentUser!.uid).setData([
//                    "Title": scheduleTitle.text!,
//                    "Place": schedulePlace.text!,
//                    "Time": scheduleTime.text!,
//                    "Memo": scheduleMemo.text!,
//                    "SavedTime": current_time_string
//                ]) { err in
//                    if let err = err {
//                        print("Error adding document: \(err)")
//                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
