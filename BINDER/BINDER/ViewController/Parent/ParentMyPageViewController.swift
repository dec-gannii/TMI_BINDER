//
//  ParentSettingViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import Firebase
import Kingfisher
import FirebaseStorage
import Photos
import FirebaseFirestore

class ParentMyPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let db = Firestore.firestore()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let storage = Storage.storage()
    var storageRef:StorageReference!
    var profile:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        viewDecorating()
        storageRef = storage.reference()
        imageChange()
        self.profileImageView.makeCircle()
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var childInfoBackgroundView: UIView!
    @IBOutlet weak var childPhoneNumberLabel: UILabel!
    @IBOutlet weak var childNameLabel: UILabel!
    
    @IBAction func DeleteChildInfoBtnClicked(_ sender: Any) {
    }
    
    @IBAction func LogoutBtnClicked(_ sender: Any) {
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
    
    @IBAction func GoSettingPageBtnClicked(_ sender: Any) {
        guard let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else {
            //아니면 종료
            return
        }
        settingVC.modalTransitionStyle = .crossDissolve
        settingVC.modalPresentationStyle = .fullScreen
        
        self.present(settingVC, animated: true, completion: nil)
    }
    
    func viewDecorating(){
        childInfoBackgroundView.layer.cornerRadius = 10
        
        childInfoBackgroundView.layer.shadowColor = UIColor.black.cgColor
        childInfoBackgroundView.layer.masksToBounds = false
        childInfoBackgroundView.layer.shadowOffset = CGSize(width: 2, height: 3)
        childInfoBackgroundView.layer.shadowRadius = 5
        childInfoBackgroundView.layer.shadowOpacity = 0.3
    }
    
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
                        let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                        let name = document.data()["name"] as? String ?? ""
                        let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                        
                        var childPhoneNumberWithDash = ""
                        
                        if (childPhoneNumber.contains("-")) {
                            childPhoneNumberWithDash = childPhoneNumber
                        } else {
                            var firstPart = ""
                            var secondPart = ""
                            var thirdPart = ""
                            var count = 0
                            
                            for char in childPhoneNumber{
                                if (count >= 0 && count <= 2) {
                                    firstPart += String(char)
                                } else if (count >= 3 && count <= 6){
                                    secondPart += String(char)
                                } else if (count >= 7 && count <= 11){
                                    thirdPart += String(char)
                                }
                                count = count + 1
                                
                            }
                            childPhoneNumberWithDash = firstPart + " - " + secondPart + " - " + thirdPart
                        }
                        db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumberWithDash).getDocuments { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                if let err = err {
                                    print("Error getting documents(inMyClassView): \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let childName = document.data()["name"] as? String ?? ""
                                        self.childNameLabel.text = childName + " 학생"
                                    }
                                }
                            }
                        }
                        self.childPhoneNumberLabel.text = childPhoneNumberWithDash
                        self.nameLabel.text = name
                        let url = URL(string: profile)!
                        self.profileImageView.kf.setImage(with: url)
                        self.profileImageView.makeCircle()
                    }
                }
            }
        }
    }
    
    func imageChange(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchToPickPhoto))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        if let url = info[.imageURL] as? URL {
            profile = (url.lastPathComponent as NSString).deletingPathExtension
        }
        
        profileImageView.image = selectedImage
        saveImage()
    }
    
    func saveImage(){
        let image = profileImageView.image!
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
                    
                    self.db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
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

