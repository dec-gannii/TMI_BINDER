//
//  TeacherEvaluationViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/15.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

public class TeacherEvaluationViewController: UIViewController {
    let db = Firestore.firestore()
    
    @IBOutlet var studentTitle: UILabel!
    @IBOutlet var TeacherTitle: UILabel!
    @IBOutlet var averageHomeworkCompletion: UILabel!
    @IBOutlet var averageClassAttitude: UILabel!
    @IBOutlet var averageTestScore: UILabel!
    @IBOutlet var evaluationTextView: UITextView!
    @IBOutlet var teacherAttitude: UITextField!
    @IBOutlet var teacherManagingSatisfyScore: UITextField!
    @IBOutlet weak var okBtn: UIButton!
    
    var teacherName: String!
    var teacherEmail: String!
    var subject: String!
    var month: String!
    var date: String!
    var studentName: String!
    var teacherUid: String!
    var viewDesign = ViewDesign()
    var btnDesign = ButtonDesign()
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        GetEvaluation(self: self)
        GetUserAndClassInfo(self: self)
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        evaluationTextView.textContainerInset = viewDesign.EdgeInsets
        self.TeacherTitle.text = self.teacherName + " 선생님의 " + self.month + " 수업은..." // 선생님 평가 title 설정
        
        evaluationTextView.clipsToBounds = true
        evaluationTextView.layer.cornerRadius = btnDesign.cornerRadius
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = btnDesign.cornerRadius
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        GetEvaluation(self: self)
        GetUserAndClassInfo(self: self) // 사용자 정보 가져오기
    }
    
    /// 선생님 평가 저장 버튼 클릭 시 실행되는 메소드
    @IBAction func SaveTeacherEvaluation(_ sender: Any) {
        BINDER.SaveTeacherEvaluation(self: self)
        // modal dismiss
        self.dismiss(animated: true, completion: nil)
    }
}
