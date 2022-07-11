//
//  QuestionDetailViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2022/03/01.
//

import UIKit
import Kingfisher

public class QuestionDetailViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var questionContent: UITextView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var answerBtn: UIButton!
    
    // 값을 받아오기 위한 변수들
    var userName : String!
    var subject : String!
    var email : String!
    var type = ""
    var index : Int!
    var qnum: Int!
    var teacherUid: String!
    
    var functionShare = FunctionShare()
    var questionDB = QuestionDBFunctions()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        questionDB.GetUserInfoInQuestionDetailVC(self: self)
    }
    
    @IBAction func undoBtn(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func clickanswerBtn(_ sender: Any) {
        guard let pvc = self.presentingViewController else { return }

        guard let answerVC = self.storyboard?.instantiateViewController(withIdentifier: "AnswerVC") as? AnswerViewController else { return }
        
        answerVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        answerVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        /// first : 여러개가 와도 첫번째 것만 봄.
        
        answerVC.index = index
        answerVC.qnum = qnum
        answerVC.email = email
        answerVC.userName = userName
        answerVC.type = type
        answerVC.subject = subject
        
        self.dismiss(animated: true) {
            pvc.present(answerVC, animated: true, completion: nil)
        }
    }
    
    // 질문 리스트 가져오기
    func setQuestion() {
        functionShare.LoadingShow(sec: 2.0)
        questionDB.SetQuestion(self: self)
    }
}
