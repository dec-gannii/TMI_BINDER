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

class QnADetailViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if avPlayerLayer == nil { print("usernameVFXView.layer is nil") ; return }
        avPlayerLayer.frame = answerView.layer.bounds
    }
    
    func getUserInfo() {
        var docRef = self.db.collection("teacher") // 선생님이면
        docRef.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents { // 문서가 있다면
                        print("\(document.documentID) => \(document.data())")
                        self.type = "teacher"
                        
                        if let index = self.index { // userIndex가 nil이 아니라면
                            // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                            print ("index : \(index)")
                            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                                .getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                        } else {
                                            for document in querySnapshot!.documents {
                                                print("\(document.documentID) => \(document.data())")
                                                // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                                // 네비게이션 바의 이름도 설정해주기
                                                let name = document.data()["name"] as? String ?? ""
                                                self.userName = name
                                                self.email = document.data()["email"] as? String ?? ""
                                                self.subject = document.data()["subject"] as? String ?? ""
                                                self.subjectName.text = self.subject
                                                self.navigationBar.topItem!.title = self.userName + " 학생"
                                                self.setQnA()
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        
        docRef = self.db.collection("student") // 학생이면
        docRef.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid) // Uid 필드가 현재 로그인한 사용자의 Uid와 같은 필드 찾기
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents { // 문서가 있다면
                        print("\(document.documentID) => \(document.data())")
                        
                        if let index = self.index { // userIndex가 nil이 아니라면
                            // index가 현재 관리하는 학생의 인덱스와 동일한지 비교 후 같은 학생의 데이터 가져오기
                            self.type = "student"
                            print ("index : \(index)")
                            self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index)
                                .getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                        } else {
                                            for document in querySnapshot!.documents {
                                                print("\(document.documentID) => \(document.data())")
                                                // 이름과 이메일, 과목 등을 가져와서 각각을 저장할 변수에 저장
                                                // 네비게이션 바의 이름도 설정해주기
                                                let name = document.data()["name"] as? String ?? ""
                                                let email = document.data()["email"] as? String ?? ""
                                                let subject = document.data()["subject"] as? String ?? ""
                                                self.subjectName.text = subject
                                                self.navigationBar.topItem!.title = name + " 선생님"
                                                
                                                self.db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").document(name + "(" + email + ") " + subject).collection("questionList").getDocuments() {(document, error) in
                                                    self.setQnA()
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
    }
    
    
    /// 질문방 내용 세팅
    // 질문 리스트 가져오기
    func setQnA() {
//        LoadingHUD.show()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            LoadingHUD.hide()
//        }
        let db = Firestore.firestore()
        // Auth.auth().currentUser!.uid
        //db.collection("student").getDocuments(){ (querySnapshot, err) in
        if (self.type == "teacher") {
            if let qnum = self.qnum {
                //질문 내용
                db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").whereField("num", isEqualTo: String(qnum)).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        /// nil이 아닌지 확인한다.
                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                            return
                        }
                        for document in snapshot.documents {
                            print(">>>>> 질문 document 정보 : \(document.documentID) => \(document.data())")
                            
                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                            let questionDt = document.data()
                            
                            /// nil값 처리
                            let title = questionDt["title"] as? String ?? ""
                            let questionContent = questionDt["questionContent"] as? String ?? ""
                            let imgURL = questionDt["imgURL"] as? String ?? ""
                            
                            self.titleName.text = title
                            self.questionContent.text = questionContent
                            self.questionContent.translatesAutoresizingMaskIntoConstraints = true
                            self.questionContent.sizeToFit()
                            self.questionContent.isScrollEnabled = false
                            
                            if imgURL != "" {
                                let url = URL(string: imgURL)
                                DispatchQueue.global().async {
                                    let data = try? Data(contentsOf: url!)
                                    DispatchQueue.main.async {
                                        self.questionImgView.image = UIImage(data: data!)
                                        self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + self.questionImgView.frame.height + 50)
                                            .isActive = true
                                    }
                                }
                            } else if (imgURL == "") {
                                self.answerImgView.removeFromSuperview()
                                self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + 50)
                                    .isActive = true
                            }
                        }
                        
                        //답변 내용
                        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.userName + "(" + self.email + ") " + self.subject).collection("questionList").document(String(qnum)).collection("answer").whereField("isAnswer", isEqualTo: true).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                /// nil이 아닌지 확인한다.
                                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                    return
                                }
                                
                                for document in snapshot.documents {
                                    print("답변: >>>>> document 정보 : \(document.documentID) => \(document.data())")
                                    
                                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                                    let questionDt = document.data()
                                    
                                    let answer = questionDt["answerContent"] as? String ?? ""
                                    let imgurl = questionDt["url"] as? String ?? ""
                                    let imgType = questionDt["type"] as? String ?? ""
                                    
                                    self.answerContent.text = answer
                                    self.answerContent.translatesAutoresizingMaskIntoConstraints = true
                                    self.answerContent.sizeToFit()
                                    self.answerContent.isScrollEnabled = false
                                    
                                    if (imgurl == "" || imgurl == "nil") {
                                        if (self.answerImgView != nil) {
                                            self.answerImgView.image = .none
                                            self.answerImgView.removeFromSuperview()
                                            self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + 50)
                                                .isActive = true
                                        }
                                    } else {
                                        if imgType == "image"{
                                            let url = URL(string: imgurl)
                                            DispatchQueue.global().async {
                                                let data = try? Data(contentsOf: url!)
                                                DispatchQueue.main.async {
                                                    if (self.answerImgView != nil) {
                                                        self.answerImgView.image = UIImage(data: data!)
                                                        self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + self.answerImgView.frame.height + 50)
                                                            .isActive = true
                                                    }
                                                }
                                            }
                                        } else {
                                            let url = URL(string: imgurl)
                                            self.player = AVPlayer(url: url!)
                                            self.avPlayerLayer = AVPlayerLayer(player: self.player)
                                            self.avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
                                            self.videourl = url
                                            self.answerView.layer.addSublayer(self.avPlayerLayer)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            LoadingHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                LoadingHUD.hide()
            }
        } else { //학생이면
            if let index = self.index {
                print ("self.index : \(index)")
                var studentName = ""
                var studentEmail = ""
                var teacherUid = ""
                
                db.collection("student").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                        
                    } else {
                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                            return
                        }
                        for document in querySnapshot!.documents {
                            studentName = document.data()["name"] as? String ?? ""
                            studentEmail = document.data()["email"] as? String ?? ""
                            db.collection("student").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: index).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                    
                                } else {
                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                        return
                                    }
                                    var teacherEmail = ""
                                    for document in querySnapshot!.documents {
                                        teacherEmail = document.data()["email"] as? String ?? ""
                                    }
                                    
                                    db.collection("teacher").whereField("email", isEqualTo: teacherEmail).getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            print(">>>>> document 에러 : \(err)")
                                            
                                        } else {
                                            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                return
                                            }
                                            
                                            for document in querySnapshot!.documents {
                                                teacherUid = document.data()["uid"] as? String ?? ""
                                                self.teacherUid = teacherUid
                                                print ("TeacherUID : \(teacherUid)")
                                                print("qnum : \(self.qnum)")
                                                //질문 내용
                                                db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").whereField("num", isEqualTo: String(self.qnum!)).getDocuments() { (querySnapshot, err) in
                                                    if let err = err {
                                                        print(">>>>> document 에러 : \(err)")
                                                    } else {
                                                        /// nil이 아닌지 확인한다.
                                                        guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                            return
                                                        }
                                                        
                                                        for document in snapshot.documents {
                                                            print(">>>>> 자세한 document 정보 : \(document.documentID) => \(document.data())")
                                                            
                                                            /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                            let questionDt = document.data()
                                                            
                                                            /// nil값 처리
                                                            let title = questionDt["title"] as? String ?? ""
                                                            let questionContent = questionDt["questionContent"] as? String ?? ""
                                                            let imgURL = questionDt["imgURL"] as? String ?? ""
                                                            
                                                            self.titleName.text = title
                                                            self.questionContent.text = questionContent
                                                            self.questionContent.translatesAutoresizingMaskIntoConstraints = true
                                                            self.questionContent.sizeToFit()
                                                            self.questionContent.isScrollEnabled = false
                                                            
                                                            if imgURL != "" {
                                                                let url = URL(string: imgURL)
                                                                DispatchQueue.global().async {
                                                                    let data = try? Data(contentsOf: url!)
                                                                    DispatchQueue.main.async {
                                                                        self.questionImgView.image = UIImage(data: data!)
                                                                        self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + self.questionImgView.frame.height + 50)
                                                                            .isActive = true
                                                                        
                                                                    }
                                                                }
                                                            } else if (imgURL == "") {
                                                                self.answerImgView.removeFromSuperview()
                                                                self.questionView.heightAnchor.constraint(equalToConstant: self.questionContent.frame.height + 50)
                                                                    .isActive = true
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            //답변 내용
                                            self.db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + self.subject).collection("questionList").document(String(self.qnum!)).collection("answer").whereField("isAnswer", isEqualTo: true).getDocuments() { (querySnapshot, err) in
                                                if let err = err {
                                                    print(">>>>> document 에러 : \(err)")
                                                } else {
                                                    /// nil이 아닌지 확인한다.
                                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                                        return
                                                    }
                                                    
                                                    for document in snapshot.documents {
                                                        print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                                                        
                                                        /// document.data()를 통해서 값 받아옴, data는 dictionary
                                                        let questionDt = document.data()
                                                        
                                                        let answer = questionDt["answerContent"] as? String ?? ""
                                                        let imgurl = questionDt["url"] as? String ?? ""
                                                        let imgType = questionDt["type"] as? String ?? ""
                                                        
                                                        self.answerContent.text = answer
                                                        self.answerContent.translatesAutoresizingMaskIntoConstraints = true
                                                        self.answerContent.sizeToFit()
                                                        self.answerContent.isScrollEnabled = false
                                                        
                                                        if (imgurl == "" || imgurl == "nil") {
                                                            if (self.answerImgView != nil) {
                                                                self.answerImgView.image = .none
                                                                self.answerImgView.removeFromSuperview()
                                                                self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + 50)
                                                                    .isActive = true
                                                            }
                                                        } else {
                                                            if imgType == "image"{
                                                                let url = URL(string: imgurl)
                                                                DispatchQueue.global().async {
                                                                    let data = try? Data(contentsOf: url!)
                                                                    DispatchQueue.main.async {
                                                                        if (self.answerImgView != nil) {
                                                                            self.answerImgView.image = UIImage(data: data!)
                                                                            self.answerView.heightAnchor.constraint(equalToConstant: self.answerContent.frame.height + self.answerImgView.frame.height + 50)
                                                                                .isActive = true
                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                let url = URL(string: imgurl)
                                                                self.player = AVPlayer(url: url!)
                                                                self.avPlayerLayer = AVPlayerLayer(player: self.player)
                                                                self.avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
                                                                self.videourl = url
                                                                self.answerView.layer.addSublayer(self.avPlayerLayer)
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingHUD.hide()
        }
        
        return
    }
}
