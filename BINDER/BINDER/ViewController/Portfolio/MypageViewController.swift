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

public class MyPageViewController: BaseVC, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var portfoiolBtn: UIButton!
    @IBOutlet weak var openPortfolioSwitch: UISwitch!
    @IBOutlet weak var portfolioPageView: UIView!
    @IBOutlet weak var pageViewTitleLabel: UILabel!
    @IBOutlet weak var portfolioNameLabel: UILabel!
    @IBOutlet weak var portolioLabel: UIView!
    @IBOutlet weak var whiteBGOnView: UIView!
    @IBOutlet weak var portfolioShowView: UIView!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let storage = Storage.storage()
    var storageRef:StorageReference!
    let db = Firestore.firestore()
    var profile:String!
    var type:String!
    var viewDesign = ViewDesign()
    var btnDesign = ButtonDesign()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = storage.reference()
        GetUserInfoForMyPage(self: self)
        GetPortfolioShow(self: self)
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
            myAlert("갤러리 접근 불가", message: StringUtils.galleryAccessFail.rawValue)
        }
    }
    
    func myAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default , handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ShowProtfolioBtnClicked(_ sender: Any) {
        PortfolioToggleButtonClicked(self: self)
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
    
    /*
    func viewDecorating(){
        pageView.layer.cornerRadius = viewDesign.viewconerRadius
        pageView.layer.shadowColor = viewDesign.shadowColor
        pageView.layer.masksToBounds = false
        pageView.layer.shadowOffset = viewDesign.shadowOffset
        pageView.layer.shadowRadius = viewDesign.shadowRadius
        pageView.layer.shadowOpacity = viewDesign.shadowOpacity
    }
    */
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        if let url = info[.imageURL] as? URL {
            profile = (url.lastPathComponent as NSString).deletingPathExtension
        }
        
        imageView.image = selectedImage
        SaveImage(self: self)
    }
}
