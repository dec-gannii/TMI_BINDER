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
class ParentMyPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    let db = Firestore.firestore()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let storage = Storage.storage()
    var storageRef:StorageReference!
    var profile:String!
    var viewDesign = ViewDesign()
    
    override func viewDidLoad() {
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
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo() // 사용자 정보 가져오기
        viewDecorating(view: childInfoBackgroundView, design: viewDesign) // 학생 전화번호 배경 view 커스터마이징
    }
    
    /// 학생 전화번호 삭제 버튼 클릭 시 실행
    @IBAction func DeleteChildInfoBtnClicked(_ sender: Any) {
        /// parent/현재 유저의 uid에서 문서를 가져와서 문서가 있다면
        self.db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                /// parent의 childPhoneNumber 를 없애주기 (공백으로 갱신)
                self.db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                    "childPhoneNumber": ""
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
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
    /*
    // 자녀 정보 background view 커스터마이징 해주기
    func viewDecorating(){
        childInfoBackgroundView.layer.cornerRadius = viewDesign.childViewconerRadius
        childInfoBackgroundView.layer.shadowColor = viewDesign.shadowColor
        childInfoBackgroundView.layer.masksToBounds = false
        childInfoBackgroundView.layer.shadowOffset = viewDesign.shadowOffset
        childInfoBackgroundView.layer.shadowRadius = viewDesign.shadowRadius
        childInfoBackgroundView.layer.shadowOpacity = viewDesign.shadowOpacity
    }
    */
    /// 사용자 정보 가져오기
    func getUserInfo() {
        let db = Firestore.firestore()
        // parent collection에서 uid 필드가 현재 사용자의 uid와 동일한 문서 찾기
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    /// 문서 존재하면
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        if LoadingHUD.isLoaded == false {
                            LoadingHUD.show()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                LoadingHUD.isLoaded = true
                                LoadingHUD.hide()
                            }
                        }
                        
                        let profile = document.data()["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png" // 학부모 프로필 이미지 링크 가져오기
                        let name = document.data()["name"] as? String ?? "" // 학부모 이름
                        let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? "" // 자녀 휴대폰 번호
                        
                        if (childPhoneNumber == "") { /// 자녀 휴대폰 번호 공백이면
                            // 자녀 휴대폰 번호 backgroundview 안 보여도 됨
                            self.childInfoBackgroundView.isHidden = true
                        } else { /// 공백 아니면
                            // 자녀 휴대폰 번호 backgroundview 보이도록 설정
                            self.childInfoBackgroundView.isHidden = false
                        }
                        
                        var childPhoneNumberWithDash = "" // '-'가 들어간 번호로 다시 만들어 주기 위해 사용
                        if (childPhoneNumber.contains("-")) { /// '-'가 있는 휴대폰 번호의 경우
                            childPhoneNumberWithDash = childPhoneNumber // '-'가 들어간 번호 변수에 그대로 사용
                        } else {  /// '-'가 없는 휴대폰 번호의 경우
                            var firstPart = "" // 010 파트
                            var secondPart = "" // 중간 번호 파트
                            var thirdPart = "" // 끝 번호 파트
                            var count = 0 // 몇 개의 숫자를 셌는지 파악하기 위한 변수
                            
                            for char in childPhoneNumber{ // childPhoneNumber가 String이므로 하나하나의 문자를 사용
                                if (count >= 0 && count <= 2) { // 0-2번째에 해당하는 수는 010 파트로 저장
                                    firstPart += String(char)
                                } else if (count >= 3 && count <= 6){ // 3-6번째에 해당하는 수는 중간 번호 파트로 저장
                                    secondPart += String(char)
                                } else if (count >= 7 && count <= 10){ // 7-10번째에 해당하는 수는 끝 번호 파트로 저장
                                    thirdPart += String(char)
                                }
                                // 한 번 할 때마다 count 하나씩 증가
                                count = count + 1
                                
                            }
                            // '-'가 들어간 번호 변수에 010 파트와 중간 번호 하트, 끝 번호 파트를 '-'로 연결해서 저장
                            childPhoneNumberWithDash = firstPart + " - " + secondPart + " - " + thirdPart
                        }
                        
                        // student collection에서 학생의 휴대전화번호가 '-'가 들어간 번호 변수의 값과 같다면
                        db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumberWithDash).getDocuments { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                if let err = err {
                                    print("Error getting documents(inMyClassView): \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let childName = document.data()["name"] as? String ?? "" // 학생 (자녀) 이름
                                        self.childNameLabel.text = childName + " 학생" // 자녀 이름 label의 이름으로 사용
                                    }
                                }
                            }
                        }
                        self.childPhoneNumberLabel.text = childPhoneNumberWithDash // 학생 (자녀) 휴대전화 번호 text로 지정
                        self.nameLabel.text = name // 학부모 이름 label은 가져온 학부모의 이름으로 지정
                        let url = URL(string: profile)! // url은 가져온 학부모의 profile 링크를 URL로 변환해 저장
                        self.profileImageView.kf.setImage(with: url) // profileImageView의 image를 가져온 url을 사용해 설정
                        self.profileImageView.makeCircle() // 프로필 이미지를 원으로 보이도록 설정
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
            myAlert("갤러리 접근 불가", message: StringUtils.galleryAccessFail.rawValue)
        }
    }
    
    func myAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default , handler: nil)
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
