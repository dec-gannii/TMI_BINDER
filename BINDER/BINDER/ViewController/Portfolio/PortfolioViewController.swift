//
//  PortfolioViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import Firebase

class PortfolioViewController: UIViewController {
    
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var studentListView: UIView!
    
    @IBOutlet weak var extraExpTL: UILabel!
    @IBOutlet weak var classMetTL: UILabel!
    @IBOutlet weak var eduTL: UILabel!
    
    @IBOutlet weak var contentView1: UIView!
    @IBOutlet weak var contentView2: UIView!
    @IBOutlet weak var contentView3: UIView!
    @IBOutlet weak var contentView4: UIView!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRound()
        
        getUserInfo()
        getPortfoiloInfo()
    }
    func viewRound(){
        contentView1.clipsToBounds = true
        contentView1.layer.cornerRadius = 10
        
        contentView2.clipsToBounds = true
        contentView2.layer.cornerRadius = 10
        
        contentView3.clipsToBounds = true
        contentView3.layer.cornerRadius = 10
        
        contentView4.clipsToBounds = true
        contentView4.layer.cornerRadius = 10
       
    }
    
    func getUserInfo(){
        studentListView.setNeedsDisplay()
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        if (docRef != nil){
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let name = data?["Name"] as? String ?? ""
                    self.teacherName.text = name
                    
                    let email = data?["Email"] as? String ?? ""
                    self.teacherEmail.text = email
                    
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    func getPortfoiloInfo() {
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfoilo").document("portfoilo")
        
        if (docRef != nil){
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let eduText = data?["eduHistory"] as? String ?? ""
                    self.eduTL.text = eduText
                    
                    let classText = data?["classMethod"] as? String ?? ""
                    self.classMetTL.text = classText
                    
                    let extraText = data?["extraExprience"] as? String ?? ""
                    self.extraExpTL.text = extraText
                    
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                    self.eduTL.text = "None"
                    self.classMetTL.text = "None"
                    self.extraExpTL.text = "None"
                }
            }
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
