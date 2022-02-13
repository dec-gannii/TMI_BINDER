//
//  AddStudentViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/30.
//

import UIKit
import Firebase

class AddStudentViewController: UIViewController {
    @IBOutlet weak var studentEmail: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentInfo()
    }
    
    func getStudentInfo() {
        let db = Firestore.firestore()
        
        db.collection("student").whereField("Email", isEqualTo: studentEmail.text!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let studentName = document.data()["Name"] as? String ?? ""
                        let studentEmail = document.data()["Email"] as? String ?? ""
                        
                        guard let insertClassInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "InsertClassInfoViewController") as? InsertClassInfoViewController else { return }
                        insertClassInfoVC.sName = studentName
                        insertClassInfoVC.sEmail = studentEmail
                        self.present(insertClassInfoVC, animated: true, completion: nil)
                    }
                }
            }
        
        //        let res = db.collection("student").whereField("Email", isEqualTo: studentEmail.text!)
        //        print("Result : \(res)")
        
        //        docRef.getDocument { (document, error) in
        //            if let document = document, document.exists {
        //                let data = document.data()
        //                let teacherName = data?["Name"] as? String ?? ""
        //                let teacherEmail = data?["Email"] as? String ?? ""
        //                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
        //                print("Document data: \(dataDescription)")
        //
        //                self.teacherName.text = teacherName + " 선생님"
        //                self.teacherEmail.text = teacherEmail
        //            } else {
        //                print("Document does not exist")
        //            }
        //        }
        
        
    }
    
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func NextButtonClicked(_ sender: Any) {
        if (!isValidEmail(studentEmail.text!)){
            self.errorLabel.isHidden = false
            self.errorLabel.text = "올바른 형태의 이메일이 아닙니다!"
        } else {
            self.errorLabel.isHidden = true
            getStudentInfo()
        }
    }
}

