//
//  QnADetailViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2022/03/01.
//

import UIKit
import AVKit
import Kingfisher
import Firebase

public class QnADetailViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    // 값을 받아오기 위한 변수들
    var userName : String!
    var subject : String!
    var email : String!
    var type = ""
    var qnum : Int!
    var index: Int!
    var teacherUid: String!
    var videourl: URL!
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var questionContent: UITextView!
    @IBOutlet weak var questionImgView: UIImageView!
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerView: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var answerContent: UITextView!
    @IBOutlet weak var answerImgView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        GetUserInfoInQnADetailVC(self: self)
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            LoadingHUD.hide()
        }
        self.answerContent.isEditable = false
        answerImgView.isUserInteractionEnabled = false
        imageViewClick()
    }
    
    func imageViewClick(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(btnPlayExternalMovie))
        answerImgView.addGestureRecognizer(tapGesture)
        answerImgView.isUserInteractionEnabled = true
    }
    
    @objc func btnPlayExternalMovie(sender: UITapGestureRecognizer){
        // 외부에 링크된 주소를 NSURL 형식으로 변경
        if videourl != nil {
            playVideo(url: videourl as NSURL) // 앞에서 얻은 url을 사용하여 비디오를 재생
        }
    }
    
    private func playVideo(url: NSURL){
        // AVPlayerController의 인스턴스 생성
        let playerController = AVPlayerViewController()
        // 비디오 URL로 초기화된 AVPlayer의 인스턴스 생성
        let openplayer = AVPlayer(url: url as URL)
        // AVPlayerViewController의 player 속성에 위에서 생성한 AVPlayer 인스턴스를 할당
        playerController.player = openplayer
        
        self.present(playerController, animated: true){
            openplayer.play() // 비디오 재생
        }
        
    }
    
    @IBAction func undoBtn(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if avPlayerLayer == nil { print("usernameVFXView.layer is nil") ; return }
        avPlayerLayer.frame = answerImgView.layer.bounds
    }
    
    /// 질문방 내용 세팅
    // 질문 리스트 가져오기
    func setQnA() {
        SetQnA(self: self)
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingHUD.hide()
        }
    }
}
