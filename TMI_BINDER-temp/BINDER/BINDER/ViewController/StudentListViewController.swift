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
    @IBOutlet weak var studentListView: UIView!
    
    var isStudentAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    func getUserInfo() {
        studentListView.setNeedsDisplay()
        if(isStudentAdded == true){
            isStudentAdded = false}
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
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Class")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let studentName = document.data()["StudentName"] as? String ?? ""
                        let subject = document.data()["Subject"] as? String ?? ""
                        
                        let classButton = UIButton()
                        
                        self.studentListView.addSubview(classButton)
                        classButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
                        classButton.translatesAutoresizingMaskIntoConstraints = false
                        
                        classButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
                        
                        classButton.setTitle(studentName + " " + subject, for: .normal)
                        classButton.setTitleColor(.black, for: .normal)
                        classButton.backgroundColor = .orange
                    }
                }
            }
        //
        //        if (isStudentAdded == true) {
        
        //        }
        
    }
}

