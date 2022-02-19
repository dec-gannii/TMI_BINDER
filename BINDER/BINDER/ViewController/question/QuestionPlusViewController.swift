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

class QuestionPlusViewController: UIViewController, UITextViewDelegate {

    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    let storage = Storage.storage()
    var storageRef:StorageReference!
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var questionName: UITextField!
    
    var studyMemo = "0"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        storageRef = storage.reference()
        placeholderSetting()

    }
    
    func placeholderSetting() {
        textView.delegate = self // txtvReview가 유저가 선언한 outlet
        textView.text = "질문 내용을 작성해주세요."
        textView.textColor = UIColor.lightGray
    }
        
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
            
    }
    
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
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
        print("upload")
        guard let image = imageView.image else {
            let alertVC = UIAlertController(title: "알림", message: "이미지를 선택하고 업로드 기능을 실행하세요", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            print("이미지 없음")
            return
        }
            print("이미지 있음")
        
        guard let name = questionName.text else {
            let textalertVC = UIAlertController(title: "알림", message: "질문의 위치를 작성해주세요", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            textalertVC.addAction(okAction)
            self.present(textalertVC, animated: true, completion: nil)
            print("제목 없음")
            return
        }
        print("제목 작성 완료")
        studyMemo = textView.text!
        
        if let data = image.pngData(){
            debugPrint(data)
            db.collection("student").document(Auth.auth().currentUser!.uid).collection("questionList").document("\(name)").setData([
                 "url":data
             ]) { err in
                 if let err = err {
                     print("Error adding document: \(err)")
                 }
             }
        }
        
        
        if studyMemo == "질문 내용을 작성해주세요."{
            textView.text = "질문 내용을 작성해주세요."
            
        } else {
            // 데이터 저장
            db.collection("student").document(Auth.auth().currentUser!.uid).collection("questionList").document("\(name)").updateData([
                 "question": studyMemo
             ]) { err in
                 if let err = err {
                     print("Error adding document: \(err)")
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        imageView.image = selectedImage
    }
}
