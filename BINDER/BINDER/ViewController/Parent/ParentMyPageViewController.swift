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

// 학부모 버전의 myPage 화면
public class ParentMyPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let db = Firestore.firestore()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let storage = Storage.storage()
    var storageRef:StorageReference!
    var profile:String!
    var viewDesign = ViewDesign()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = storage.reference()
        imageChange() // 이미지 변경
        self.profileImageView.makeCircle() // 프로필 이미지 동그랗게 보이도록 설정
    }
    
    @IBOutlet weak var profileImageView: UIImageView! // 프로필 이미지 띄우는 imageView
    @IBOutlet weak var nameLabel: UILabel! // 학부모 이름 label
    @IBOutlet weak var childInfoBackgroundView: UIView! // 학생 전화번호 정보 배경 view
    @IBOutlet weak var childPhoneNumberLabel: UILabel! // 학생 전화번호 Label
    @IBOutlet weak var childNameLabel: UILabel! // 학생 이름 Label
    
    public override func viewWillAppear(_ animated: Bool) {
//        getUserInfo() // 사용자 정보 가져오기
        GetParentInfo(self: self)
        viewDecorating() // 학생 전화번호 배경 view 커스터마이징
    }
    
    /// 학생 전화번호 삭제 버튼 클릭 시 실행
    @IBAction func DeleteChildInfoBtnClicked(_ sender: Any) {
        DeleteChildPhone()
        // 없애고 나면 전화번호가 없는 것이므로 아예 숨겨주기
        self.childInfoBackgroundView.isHidden = true
    }
    
    /// 로그아웃 버튼 클릭 시 실행
    @IBAction func LogoutBtnClicked(_ sender: Any) {
        do {
            /// 로그아웃 실행
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
        
        /// 사용자가 있으면
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
            loginVC.isLogouted = true // 로그아웃 시 자동 로그인을 막기 위해서 로그아웃됨을 나타내는 bool 변수를 true로 설정
            
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    /// 설정 버튼 클릭 시 실행
    @IBAction func GoSettingPageBtnClicked(_ sender: Any) {
        // 설정 viewcontroller로 이동
        guard let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else {
            //아니면 종료
            return
        }
        settingVC.modalTransitionStyle = .crossDissolve
        settingVC.modalPresentationStyle = .fullScreen
        
        self.present(settingVC, animated: true, completion: nil)
    }
    
    // 자녀 정보 background view 커스터마이징 해주기
    func viewDecorating(){
        childInfoBackgroundView.layer.cornerRadius = viewDesign.childViewconerRadius
        childInfoBackgroundView.layer.shadowColor = viewDesign.shadowColor
        childInfoBackgroundView.layer.masksToBounds = false
        childInfoBackgroundView.layer.shadowOffset = viewDesign.shadowOffset
        childInfoBackgroundView.layer.shadowRadius = viewDesign.shadowRadius
        childInfoBackgroundView.layer.shadowOpacity = viewDesign.shadowOpacity
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
            myAlert("갤러리 접근 불가", message: StringUtils.galleryAccessFail.rawValue)
        }
    }
    
    func myAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default , handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        if let url = info[.imageURL] as? URL {
            profile = (url.lastPathComponent as NSString).deletingPathExtension
        }
        
        profileImageView.image = selectedImage
        SaveProfileImage(self: self, profile: self.profile!)
    }
}
