//
//  QuestionViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/11.
//

import UIKit
import Kingfisher
import Firebase
import AVFoundation

public class QuestionViewController: BaseVC {
    
    // 요소 연결(테이블 뷰 X)
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    
    // 테이블 뷰 연결
    @IBOutlet weak var questionTV: UITableView!
    
    let db = Firestore.firestore()
    var docRef : CollectionReference!
    
    // 값을 넘겨주기 위한 변수들
    var index : Int!
    var email : String!
    var subject : String!
    var name : String!
    var classColor : String!
    var type = ""       // 유저의 타입
    var questionItems: [QuestionItem] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        GetUserInfoInQuestionVC(self: self)
    }
    
    /// 선생님 셋팅
    func setTeacherInfo() {
        LoginRepository.shared.doLogin {
            /// 가져오는 시간 걸림
            self.teacherName.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
            self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
            
            let url = URL(string: LoginRepository.shared.teacherItem!.profile)
            self.teacherImage.kf.setImage(with: url)
            self.teacherImage.makeCircle()
            
            /// 클래스 가져오기
            self.setQuestionroom()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    /// 학생 셋팅
    func setStudentInfo() {
        LoginRepository.shared.doLogin {
            /// 가져오는 시간 걸림
            self.teacherName.text = "\(LoginRepository.shared.studentItem!.name) 학생"
            self.teacherEmail.text = LoginRepository.shared.studentItem!.email
            
            /// 클래스 가져오기
            self.setQuestionroom()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    /// 질문방 내용 세팅
    // 내 수업 가져오기
    func setQuestionroom() {
        SetQuestionRoom(self: self)
    }
}


// MARK: - 테이블뷰 관련

extension QuestionViewController: UITableViewDelegate, UITableViewDataSource {
    /// 테이블 셀 개수
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "question")! as! QuestionTableViewCell
        
        let item:QuestionItem = questionItems[indexPath.row]
        
        if (userType == "teacher") {
            cell.studentName.text = "\(item.userName) 학생"
        } else {
            cell.studentName.text = "\(item.userName) 선생님"
        }
        
        cell.subjectName.text = item.subjectName
        cell.classColor.allRoundSmall()
        if let hex = Int(item.classColor, radix: 16) {
            cell.classColor.backgroundColor = UIColor.init(rgb: hex)
        } else {
            cell.classColor.backgroundColor = UIColor.red
        }
        
        cell.contentView.tag = item.index
        
        return cell
        
    }
    
    /// didDelectRowAt: 셀 전체 클릭
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        QuestionCellClicked(self: self, indexPath: indexPath)
    }
}
