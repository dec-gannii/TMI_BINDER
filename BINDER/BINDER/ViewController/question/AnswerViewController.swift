//
//  AnswerViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2022/02/20.
//

import UIKit
import MobileCoreServices
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Photos

class AnswerViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate{
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    let storage = Storage.storage()
    var storageRef:StorageReference!
    var name:String!
    
    // 값을 받아오기 위한 변수들
    var userName : String!
    var subject : String!
    var email : String!
    var type = ""
    var index : Int!
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // UIImagePickerController의 인스턴스 변수 생성
        let imagePicker: UIImagePickerController! = UIImagePickerController()

        var captureImage: UIImage!
        var videoURL: URL!
        var flagImageSave = false
        var imgtype:Int = 0
        var answer = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // TextView Place Holders
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "질문 내용을 작성해주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        print("select")
        
        let actionSheet = UIAlertController(title: "사진 또는 영상 선택", message: "사진의 위치를 선택해주세요.", preferredStyle: .actionSheet)
        // 취소 버튼 추가
        let action_cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        actionSheet.addAction(action_cancel)
        
        //영상 버튼 추가
        let action_video = UIAlertAction(title: "영상", style: .default) { (action) in
            self.showVideo()
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
        actionSheet.addAction(action_video)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    // 사진 불러오기
    func showGallery() {
            
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
                flagImageSave = false
                
                imagePicker.delegate = self
                // 이미지 피커의 소스 타입을 PhotoLibrary로 설정
                imagePicker.sourceType = .photoLibrary
                
                imagePicker.mediaTypes = [kUTTypeImage as String]
                // 편집을 허용
                imagePicker.allowsEditing = true
                
                present(imagePicker, animated: true, completion: nil)
            } else {
                myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
            }
        }
    
    // 비디오 불러오기
        func showVideo() {
            
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
                flagImageSave = false
                
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                
                present(imagePicker, animated: true, completion: nil)
            } else {
                myAlert("Photo album inaccessable", message: "Application cannot access the photo album")
            }
        }
    
    // 사진, 비디오 촬영이나 선택이 끝났을 때 호출되는 델리게이트 메서드
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 미디어 종류 확인
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
           
            // 미디어 종류가 사진(Image)일 경우
            if mediaType.isEqual(to: kUTTypeImage as NSString as String){
                
                // 사진을 가져와 captureImage에 저장
                captureImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
                imgtype = 1
                
                if flagImageSave { // flagImageSave가 true이면
                    // 사진을 포토 라이브러리에 저장
                    UIImageWriteToSavedPhotosAlbum(captureImage, self, nil, nil)
                }
                imgView.image = captureImage // 가져온 사진을 이미지 뷰에 출력
            
            // 미디어 종류가 비디오(Movie)일 경우
            } else if mediaType.isEqual(to: kUTTypeMovie as NSString as String) {
                 
                if flagImageSave { // flagImageSave가 true이면
                    // 촬영한 비디오를 옴
                    videoURL = (info[UIImagePickerController.InfoKey.mediaURL] as! URL)
                    imgtype = 2
                    // 비디오를 포토 라이브러리에 저장
                    UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, nil, nil)
                }
            }
            
            
            // 현재의 뷰 컨트롤러를 제거. 즉, 뷰에서 이미지 피커 화면을 제거하여 초기 뷰를 보여줌
            self.dismiss(animated: true, completion: nil)
        }
        
        // 사진, 비디오 촬영이나 선택을 취소했을 때 호출되는 델리게이트 메서드
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 현재의 뷰(이미지 피커) 제거
            self.dismiss(animated: true, completion: nil)
        }
        
        // 경고 창 출력 함수
        func myAlert(_ title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default , handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    
    
    @IBAction func btnAnswer(_ sender: Any) {
        print("upload")
        guard let image = imgView.image else {
            let alertVC = UIAlertController(title: "알림", message: "이미지 또는 영상을 선택하고 업로드 기능을 실행하세요", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            print("이미지 없음")
            return
        }
            print("이미지 있음")
        
        answer = textView.text
        
        if answer == "질문 내용을 작성해주세요." {
            let textalertVC = UIAlertController(title: "알림", message: "질문의 위치 또는 질문 내용을 작성해주세요", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            textalertVC.addAction(okAction)
            self.present(textalertVC, animated: true, completion: nil)
            print("제목 없음")
        } else {
            if imgtype == 1 {
                if let data = image.pngData(){
                    let urlRef = storageRef.child("image/\(captureImage!).png")
                    
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
                            self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("questionList").document(self.name).collection("answer").document(Auth.auth().currentUser!.uid).setData([
                                "url":"\(downloadURL)",
                                "answer": self.answer
                             ]) { err in
                                 if let err = err {
                                     print("Error adding document: \(err)")
                                 }
                             }
                        }
                    }
                }
            } else {
                self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("questionList").document(self.name).collection("answer").document(Auth.auth().currentUser!.uid).setData([
                    "url":"\(videoURL)",
                     "answer": answer
                 ]) { err in
                     if let err = err {
                         print("Error adding document: \(err)")
                     }
                 }
            }
        }
    }
}
