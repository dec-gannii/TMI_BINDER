//
//  AnswerViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2022/02/20.
//

import UIKit
import AVKit
import MobileCoreServices
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Photos

public class AnswerViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate{
    
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
    var qnum : Int!
    var vnull = true
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
    var tname : String!
    var fcmtoken: String!
    
    var viewDesign = ViewDesign()
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // UIImagePickerController의 인스턴스 변수 생성
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let notification = PushNotificationSender()
    
    var newImage: UIImage!
    var videoURL: URL!
    var flagImageSave = false
    var imgtype:Int = 1
    var answer = "0"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = storage.reference()
        placeholderSetting()
        getNameFcm()
        textView.textContainerInset = viewDesign.EdgeInsets
    }
    
    @IBAction func undoBtn(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func placeholderSetting() {
        textView.delegate = self // txtvReview가 유저가 선언한 outlet
        textView.text = "답변 내용을 작성해주세요."
        textView.textColor = UIColor.lightGray
    }
    
    // TextView Place Holder
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // TextView Place Holders
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "답변 내용을 작성해주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
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
            myAlert("권한 필요", message: "사진첩 접근 권한이 필요합니다. 설정 화면에서 설정해주세요.")
        }
    }
    
    // 비디오 불러오기
    func showVideo() {
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            flagImageSave = true
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        } else {
            myAlert("권한 필요", message: "사진첩 접근 권한이 필요합니다. 설정 화면에서 설정해주세요.")
        }
    }
    
    // 사진, 비디오 촬영이나 선택이 끝났을 때 호출되는 델리게이트 메서드
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 미디어 종류 확인
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        // 미디어 종류가 사진(Image)일 경우
        if mediaType.isEqual(to: kUTTypeImage as NSString as String){
            
            if let captureImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                newImage = captureImage // 수정된 이미지가 있을 경우
            } else if let captureImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                newImage = captureImage // 원본 이미지가 있을 경우
            }
            imgtype = 1
            
            if flagImageSave { // flagImageSave가 true이면
                // 사진을 포토 라이브러리에 저장
                UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil)
            }
            imgView.image = newImage // 가져온 사진을 이미지 뷰에 출력
            
            // 미디어 종류가 비디오(Movie)일 경우
        } else if mediaType.isEqual(to: kUTTypeMovie as NSString as String) {
            
            if flagImageSave { // flagImageSave가 true이면
                // 촬영한 비디오를 옴
                videoURL = (info[UIImagePickerController.InfoKey.mediaURL] as! URL)
                imgtype = 2
                // 비디오를 포토 라이브러리에 저장
                UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, nil, nil)
            }
            //url에 정확한 이미지 url 주소를 넣는다.
            videoinImage()
        }
        
        // 현재의 뷰 컨트롤러를 제거. 즉, 뷰에서 이미지 피커 화면을 제거하여 초기 뷰를 보여줌
        self.dismiss(animated: true, completion: nil)
    }
    
    func videoinImage(){
        
        player = AVPlayer(url: videoURL!)
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
        
        imgView.layer.addSublayer(avPlayerLayer)
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if avPlayerLayer == nil { print("usernameVFXView.layer is nil") ; return }
        avPlayerLayer.frame = imgView.layer.bounds
    }
    
    // 사진, 비디오 촬영이나 선택을 취소했을 때 호출되는 델리게이트 메서드
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
        answer = textView.text
        UpdateAnswer(answer: answer, imgtype: self.imgtype, self: self, imgView: self.imgView)
        
        notification.sendPushNotification(token: fcmtoken, title: "답변이 올라왔어요!", body: "\(tname!) 선생님이 답변을 달았어요.")
        
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func getNameFcm(){
        let db = Firestore.firestore()
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.tname = data?["name"] as? String ?? ""
                
            } else {
                print("Document does not exist")
            }
        }
        db.collection("student").whereField("name", isEqualTo: self.userName!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    /// 문서 존재하면
                    for document in querySnapshot!.documents {
                        self.fcmtoken = document.data()["fcmToken"] as? String ?? ""
                    }
                }
            }
        }
    }
}
