//
//  StudentEvaluationCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class StudentEvaluationCell: UITableViewCell, UITextFieldDelegate {
    let nowDate = Date()
    let cellDBFunctionShare = StudentEvaluationCellDBFunctions()
    
    @IBOutlet weak var classColorView: UIView!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var showMoreInfoButton: UIButton!
    @IBOutlet weak var TeacherNameLabel: UILabel! // 선생님 이름 Label
    @IBOutlet weak var isRecorededLabel: UILabel!
    
    var selectedMonth = ""
    var evaluation = ""
    var studentUid = ""
    var teacherName = ""
    var teacherEmail = ""
    var subject = ""
    
    func setStudentUID(_ studentUid: String) {
        self.studentUid = studentUid
    }
    
    func setTeacherInfo(_ teacherName: String, _ teacherEmail: String, _ subject: String) {
        self.teacherName = teacherName
        self.teacherEmail = teacherEmail
        self.subject = subject
        cellDBFunctionShare.GetEvaluation(self: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        LoadingHUD.isLoaded = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        self.selectedMonth = dateFormatter.string(from: self.nowDate) + "월"
        
        cellBackgroundView.clipsToBounds = true
        cellBackgroundView.layer.cornerRadius = 15
        
        self.selectionStyle = .none
    }
}
