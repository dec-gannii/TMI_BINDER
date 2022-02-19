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
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // UIImagePickerController의 인스턴스 변수 생성
        let imagePicker: UIImagePickerController! = UIImagePickerController()

        var captureImage: UIImage!
        var videoURL: URL!
        var flagImageSave = false
    
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
    
    // 사진 불러오기
        @IBAction func btnLoadImageFromLibrary(_ sender: UIButton) {
            
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
        @IBAction func btnLoadVideoFromLibrary(_ sender: UIButton) {
            
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
            let alertVC = UIAlertController(title: "알림", message: "이미지를 선택하고 업로드 기능을 실행하세요", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            print("이미지 없음")
            return
        }
            print("이미지 있음")
        if let data = image.pngData(){
            debugPrint(data)
            db.collection("student").document(Auth.auth().currentUser!.uid).collection("questionList").document("answer").setData([
                 "url":data
             ]) { err in
                 if let err = err {
                     print("Error adding document: \(err)")
                 }
             }
        }
        
        answer = textView.text!
        if answer == "답변 내용을 작성해주세요."{
            textView.text = "답변 내용을 작성해주세요."
            
        } else {
            // 데이터 저장
            db.collection("student").document(Auth.auth().currentUser!.uid).collection("questionList").document("answer").setData([
                 "answer": answer
             ]) { err in
                 if let err = err {
                     print("Error adding document: \(err)")
                 }
             }
        }
        
    }
    
}
