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
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Class").document(sName + "(" + sEmail + ") " + subjectTextField.text!).setData([
                "StudentName": sName,
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
            
            guard let studentListVC = self.storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController else { return }
            
            studentListVC.isStudentAdded = true
            // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
            //            self.present(studentListVC, animated: true, completion: nil)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            //
            //            studentListVC.studentListView.addSubview(classButton)
            //            classButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
            //            classButton.translatesAutoresizingMaskIntoConstraints = false
            //
            //            classButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
            //
            //            classButton.setTitle("OK", for: .normal)
            //            classButton.setTitleColor(.black, for: .normal)
            //            classButton.backgroundColor = .orange
            //            self.dismiss(animated: true, completion: nil)
        }
    }
}
