//
//  PortfolioViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import Firebase
import Kingfisher

class PortfolioViewController: UIViewController {
    
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var studentListView: UIView!
    
    @IBOutlet weak var teacherEvaluationTL: UILabel!
    @IBOutlet weak var extraExpTL: UILabel!
    @IBOutlet weak var classMetTL: UILabel!
    @IBOutlet weak var eduTL: UILabel!
    
    @IBOutlet weak var contentView1: UIView!
    @IBOutlet weak var contentView2: UIView!
    @IBOutlet weak var contentView3: UIView!
    @IBOutlet weak var contentView4: UIView!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    
    var isShowMode: Bool = false
    var showModeEmail: String = ""
    var isShowOK: Bool = false
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRound()
        getUserInfo()
        getPortfoiloInfo()
        
        if (isShowMode == true) {
            self.editBtn.isHidden = true
        } else {
            self.editBtn.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewRound()
        getUserInfo()
        getPortfoiloInfo()
        
        if (isShowMode == true) {
            self.editBtn.isHidden = true
            self.plusBtn.setTitle("", for: .normal)
        } else {
            self.editBtn.isHidden = false
        }
        super.viewWillAppear(animated)
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
        if (isShowMode == true) {
            self.db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.teacherName.text = document.data()["name"] as? String ?? ""
                        self.teacherEmail.text = document.data()["email"] as? String ?? ""
                        let profile = document.data()["profile"] as? String ?? ""
                        
                        self.teacherImage.kf.setImage(with: URL(string: profile)!)
                    }
                }
            }
        } else {
            let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let name = data?["name"] as? String ?? ""
                    self.teacherName.text = name
                    
                    let email = data?["email"] as? String ?? ""
                    self.teacherEmail.text = email
                    
                    let profile = document.data()!["profile"] as? String ?? ""
                    
                    self.teacherImage.kf.setImage(with: URL(string: profile)!)
                    
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    func getPortfoiloInfo() {
        if (isShowMode == false){
            let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio")
            
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
        } else {
            var teacherUid = ""
            self.db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        teacherUid = document.data()["uid"] as? String ?? ""
                        self.db.collection("teacher").document(teacherUid).collection("Portfolio").document("portfolio").getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                let portfolioAccess = data?["portfolioShow"] as? String ?? ""
                                if (portfolioAccess == "On") {
                                    let eduText = data?["eduHistory"] as? String ?? ""
                                    self.eduTL.text = eduText
                                    
                                    let classText = data?["classMethod"] as? String ?? ""
                                    self.classMetTL.text = classText
                                    
                                    let extraText = data?["extraExprience"] as? String ?? ""
                                    self.extraExpTL.text = extraText
                                    
                                    self.teacherEvaluationTL.text = ""
                                } else {
                                    self.eduTL.text = "비공개 설정되어 있습니다."
                                    self.teacherEvaluationTL.text = "비공개 설정되어 있습니다."
                                    self.classMetTL.text = "비공개 설정되어 있습니다."
                                    self.extraExpTL.text = "비공개 설정되어 있습니다."
                                }
                                
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
            }
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        if (isShowMode == true){
            self.dismiss(animated: true, completion: nil)
        } else {
            if let preVC = self.presentingViewController as? UIViewController {
                preVC.dismiss(animated: true, completion: nil)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
