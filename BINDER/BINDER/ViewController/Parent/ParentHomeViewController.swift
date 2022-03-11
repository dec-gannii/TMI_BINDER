//
//  ParentHomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import FirebaseDatabase
import Firebase

class ParentHomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var progressListTableView: UITableView!
    
    func getUserInfo() {
        let db = Firestore.firestore()
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let name = document.data()["name"] as? String ?? ""
                        self.parentNameLabel.text = name + " 학부모님"
                    }
                }
            }
        }
    }
}

extension ParentHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "progress")! as! StudentEvaluationCell
        return cell
    }
    
    
}
