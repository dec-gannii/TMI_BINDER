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
    var isEditingMode: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateLabel.text = date
        self.scheduleMemo.layer.borderWidth = 1.0
        self.scheduleMemo.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    @IBAction func AddScheduleSubmitBtn(_ sender: Any) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        var formatter_time = DateFormatter()
        formatter_time.dateFormat = "YYYY-MM-dd HH:mm"
        var current_time_string = formatter_time.string(from: Date())
        
        if (scheduleTitle.text != "") {
            if ((scheduleTitle.text?.trimmingCharacters(in: .whitespaces)) != "") {
                db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(date).document(scheduleTitle.text!).setData([
                    "Title": scheduleTitle.text!,
                    "Place": schedulePlace.text!,
                    "Date" : dateLabel.text!,
                    "Time": scheduleTime.text!,
                    "Memo": scheduleMemo.text!,
                    "SavedTime": current_time_string ])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(date).getDocuments()
                {
                    (querySnapshot, err) in
                    
                    if let err = err
                    {
                        print("Error getting documents: \(err)");
                    }
                    else
                    {
                        var count = 0
                        for document in querySnapshot!.documents {
                            count += 1
                            print("\(document.documentID) => \(document.data())");
                        }
                        
                        if (count == 1) {
                            db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document("Count").setData(["count": count])
                            { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        }else {
                            db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document("Count").setData(["count": count-1])
                            { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                }
                            }
                        }
                        print("Count = \(count)");
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
