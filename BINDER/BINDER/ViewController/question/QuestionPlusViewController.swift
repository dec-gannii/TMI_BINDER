//
//  QuestionPlusViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2022/02/19.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Photos

public class QuestionPlusViewController: UIViewController, UITextViewDelegate {
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    let notification = PushNotificationSender()
    let storage = Storage.storage()
    var storageRef:StorageReference!
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var questionName: UITextField!
    
    var studyMemo = "0"
    var file_name:String!
    var name:String!
    
    var userName : String!
    var subject : String!
    var email : String!
    var type = ""
    var index : Int!
    var qnum : Int!
    var teacherUid: String!
    var sname: String!
    var fcmtoken: String!
    
    var newImage: UIImage!
    var flagImageSave = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        /// 키보드 띄우기
        self.questionName.becomeFirstResponder()
        storageRef = storage.reference()
        placeholderSetting()
        getFcm()
        
    }
    
    @IBAction func clickUndo(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func placeholderSetting() {
        textView.delegate = self // txtvReview가 유저가 선언한 outlet
        textView.text = "질문 내용을 작성해주세요."
        textView.textColor = UIColor.lightGray
    }
    
    // TextView Place Holder
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // TextView Place Holder
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "질문 내용을 작성해주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        print("select")
        
        let actionSheet = UIAlertController(title: "사진 선택", message: "사진의 위치를 선택해주세요.", preferredStyle: .actionSheet)
        // 취소 버튼 추가
        let action_cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        actionSheet.addAction(action_cancel)
        
        //카메라 버튼 추가
        let action_camera = UIAlertAction(title: "카메라", style: .cancel) { (action) in
            self.openCamera()
        }
        
        // 갤러리 버튼 추가
        let action_gallery = UIAlertAction(title: "사진 앨범", style: .default) { action in
            print("push gallery button")
            
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                print("접근 가능")
                self.showGallery()
            case .notDetermined:
                print("권한 요청한 적 없음")
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                }
                
            default:
                let alertVC = UIAlertController(title: "권한 필요", message: "사진첩 접근 권한이 필요합니다. 설정 화면에서 설정해주세요", preferredStyle: .alert)
                
                let action_settings = UIAlertAction(title: "Go Settings", style: .default){
                    action in
                    print("go settings")
                    if let appSettings = URL(string: UIApplication.openSettingsURLString){
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
                
                alertVC.addAction(action_settings)
                alertVC.addAction(action_cancel)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(action_gallery)
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        name = questionName.text
        studyMemo = textView.text!
        
        if name == "" || studyMemo == "질문 내용을 작성해주세요." {
            let textalertVC = UIAlertController(title: "알림", message: "질문의 제목 또는 질문 내용을 작성해주세요", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            textalertVC.addAction(okAction)
            self.present(textalertVC, animated: true, completion: nil)
            print("제목 없음")
        }
        else {
            print("제목 작성 완료")
            UpdateImage(self: self)
            
            notification.sendPushNotification(token: fcmtoken, title: "선생님 질문 있어요!", body: "\(self.sname!) 학생이 질문을 올렸어요")
        }
    }
    
    func getFcm(){
        let db = Firestore.firestore()
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.sname = data?["name"] as? String ?? ""
                
            } else {
                print("Document does not exist")
            }
        }
        db.collection("teacher").whereField("name", isEqualTo: self.userName!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    /// 문서 존재하면
                    for document in querySnapshot!.documents {
                        self.fcmtoken = document.data()["fcmToken"] as? String ?? ""
                        print("fcmToken: \(self.fcmtoken)")
                    }
                }
            }
        }
    }
}

extension QuestionPlusViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func showGallery(){
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            present(imagePicker, animated: false, completion: nil)
        }
        else{
            print("Camera not available")
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let captureImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = captureImage // 수정된 이미지가 있을 경우
        } else if let captureImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = captureImage // 원본 이미지가 있을 경우
        }
        
        if let url = info[.imageURL] as? URL {
            file_name = (url.lastPathComponent as NSString).deletingPathExtension
        }
        
        imageView.image = newImage
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}
