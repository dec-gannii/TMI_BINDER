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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentInfo()
    }
    
    func getStudentInfo() {
        let db = Firestore.firestore()
        let docRef = db.collection("student").document(Auth.auth().currentUser!.uid)
        
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
                        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
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
    @IBAction func NextButtonClicked(_ sender: Any) {
        getStudentInfo()
    }
}

