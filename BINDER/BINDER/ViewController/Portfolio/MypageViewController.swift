//
//  MypageViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import FirebaseFirestore
import Firebase
import Kingfisher
import FirebaseStorage
import Photos

class MyPageViewController: BaseVC,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    
    @IBOutlet weak var portfoiolBtn: UIButton!
    @IBOutlet weak var openPortfolioSwitch: UISwitch!
    
    @IBOutlet weak var portfolioPageView: UIView!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let storage = Storage.storage()
    var storageRef:StorageReference!
    let db = Firestore.firestore()
    var profile:String!
    var type:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = storage.reference()
        openPortfolioSwitch.onTintColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
        getUserInfo()
        getPortfolioShow()
        viewDecorating()
        imageChange()
    }
    
    func imageChange(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchToPickPhoto))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func touchToPickPhoto(sender: UITapGestureRecognizer){
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            
            imagePicker.delegate = self
            // 이미지 피커의 소스 타입을 PhotoLibrary로 설정
            imagePicker.sourceType = .photoLibrary
            // 편집을 허용
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
            
        } else {
            myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
        }
    }
    
    func myAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default , handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getUserInfo(){
        var docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                LoginRepository.shared.doLogin {
                    self.nameLabel.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
                    self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
                    self.type = "teacher"
                    
                    var url: URL
                    if let photoUrl = Auth.auth().currentUser?.photoURL {
                        url = photoUrl
                    } else {
                        url = URL(string: LoginRepository.shared.teacherItem!.profile)!
                    }
                    
                    self.imageView.kf.setImage(with: url)
                    self.imageView.makeCircle()
                    
                } failure: { error in
                    self.showDefaultAlert(msg: "")
                }
            } else {
                docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let userName = data?["name"] as? String ?? ""
                        self.nameLabel.text = "\(userName) 학생"
                        let userEmail = data?["email"] as? String ?? ""
                        self.teacherEmail.text = userEmail
                        let profile =  data?["profile"] as? String ?? ""
                        self.type = "student"
                        
                        var url: URL
                        if let photoUrl = Auth.auth().currentUser?.photoURL {
                            url = photoUrl
                        } else {
                            url = URL(string: profile)!
                        }
                        
                        self.imageView.kf.setImage(with: url)
                        self.imageView.makeCircle()
                        //                        let url = Auth.auth().currentUser?.photoURL
                        
                        self.portfolioPageView.isHidden = true
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    func getPortfolioShow() {
        let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let isShowOK = data?["portfolioShow"] as? String ?? ""
                if (isShowOK == "On") {
                    self.openPortfolioSwitch.setOn(true, animated: true)
                } else {
                    self.openPortfolioSwitch.setOn(false, animated: true)
                }
                
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func ShowProtfolioBtnClicked(_ sender: Any) {
        if (self.openPortfolioSwitch.isOn) {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                "portfolioShow": "On"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
        } else {
            db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio").updateData([
                "portfolioShow": "Off"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
        }
        
    }
    
    @IBAction func LogOutBtnClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
        
        if Auth.auth().currentUser != nil {
            // Show logout page
            let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
            signinVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            signinVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(signinVC!, animated: true, completion: nil)
        } else {
            // Show login page
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else {
                //아니면 종료
                return
            }
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.isLogouted = true
            
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    func viewDecorating(){
        portfoiolBtn.layer.cornerRadius = 20
        pageView.layer.cornerRadius = 30
        
        pageView.layer.shadowColor = UIColor.black.cgColor
        pageView.layer.masksToBounds = false
        pageView.layer.shadowOffset = CGSize(width: 2, height: 3)
        pageView.layer.shadowRadius = 5
        pageView.layer.shadowOpacity = 0.3
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        if let url = info[.imageURL] as? URL {
            profile = (url.lastPathComponent as NSString).deletingPathExtension
        }
        
        imageView.image = selectedImage
        saveImage()
    }
    
    func saveImage(){
        let image = imageView.image!
        if let data = image.pngData(){
            let urlRef = storageRef.child("image/\(profile!).png")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            let uploadTask = urlRef.putData(data, metadata: metadata){ (metadata, error) in
                    guard let metadata = metadata else {
                        return
                    }
            
                urlRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        return
                    }
                    
                    self.db.collection(self.type).document(Auth.auth().currentUser!.uid).updateData([
                        "profile":"\(downloadURL)",
                     ]) { err in
                         if let err = err {
                             print("Error adding document: \(err)")
                         }
                     }
                }
            }
        }
    }
}

