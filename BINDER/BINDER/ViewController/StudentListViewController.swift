//
//  StudentListViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/30.
//


import UIKit
import Firebase

class StudentListViewController: UIViewController {
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    func getUserInfo() {
        let db = Firestore.firestore()
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let teacherName = data?["Name"] as? String ?? ""
                let teacherEmail = data?["Email"] as? String ?? ""
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                self.teacherName.text = teacherName + " 선생님"
                self.teacherEmail.text = teacherEmail
            } else {
                print("Document does not exist")
            }
        }
    }
}

