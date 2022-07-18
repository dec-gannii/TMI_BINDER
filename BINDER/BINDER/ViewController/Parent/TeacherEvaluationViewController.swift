//
//  TeacherEvaluationViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/15.
//

import UIKit

public class TeacherEvaluationViewController: UIViewController {
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
    var parentDB = ParentDBFunctions()
    var functionShare = FunctionShare()

    public override func viewDidLoad() {
        super.viewDidLoad()
        parentDB.GetEvaluation(self: self)
        parentDB.GetUserAndClassInfo(self: self)
        
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 30.0)
        
        teacherAttitude.keyboardType = .numberPad
        teacherManagingSatisfyScore.keyboardType = .numberPad
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        evaluationTextView.textContainerInset = viewDesign.EdgeInsets
        self.TeacherTitle.text = self.teacherName + " 선생님의 " + self.month + " 수업은..." // 선생님 평가 title 설정
        
        evaluationTextView.clipsToBounds = true
        evaluationTextView.layer.cornerRadius = btnDesign.cornerRadius
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = btnDesign.cornerRadius
        
        let size = CGSize(width: self.view.frame.width, height: .infinity)
        let estimatedSize = self.evaluationTextView.sizeThatFits(size)
        
        self.evaluationTextView.constraints.forEach { (constraint) in
            
            /// 180 이하일때는 더 이상 줄어들지 않게하기
            if estimatedSize.height <= 100 {
                
            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        parentDB.GetEvaluation(self: self)
        parentDB.GetUserAndClassInfo(self: self) // 사용자 정보 가져오기
    }
    
    /// 선생님 평가 저장 버튼 클릭 시 실행되는 메소드
    @IBAction func SaveTeacherEvaluation(_ sender: Any) {
        if (functionShare.CheckScore(textField: teacherAttitude) && functionShare.CheckScore(textField: teacherManagingSatisfyScore)) {
            parentDB.SaveTeacherEvaluation(self: self)
        } else {
            functionShare.AlertShow(alertTitle: "오류", message: "잘못된 입력입니다!", okTitle: "확인", self: self)
        }
        // modal dismiss
        self.dismiss(animated: true, completion: nil)
    }
}
