//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit
import Kingfisher
import Firebase

public class MyClassVC: BaseVC{
    /// 학생 리스트
    @IBOutlet weak var studentTV: UITableView!
    
    /// 수업 변수 배열
    var classItems: [ClassItem] = []
    var type = ""
    var studentEmail = ""
    
    var myClassDB = MyClassDBFunctions()
    
    // MARK: - 라이프 사이클
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    /// segue를 호출할 때, 데이터를 넘기고 싶은 경우에 사용
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // delegate 전달, AddStudentVC로 넘긴다.
        if let resultVC = segue.destination as? AddStudentVC {
            resultVC.delegate = self
        }
    }
    
    // MARK: - 기능
    
    /// 유저 정보 가져오기
    func getUserInfo() {
        myClassDB.GetUserInfoForClassList(self: self)
    }
    
    /// 선생님 셋팅
    func setTeacherInfo() {
        LoginRepository.shared.doLogin {
            /// 클래스 가져오기
            self.myClassDB.SetMyClasses(self: self)
        } failure: { error in
            self.showDefaultAlert(msg: "다시 시도해주세요.")
        }
        /// 클로저, 리스너
    }
    
    /// 학생 셋팅
    func setStudentInfo() {
        LoginRepository.shared.doLogin {
            /// 클래스 가져오기
            self.myClassDB.SetMyClasses(self: self)
        } failure: { error in
            self.showDefaultAlert(msg: "다시 시도해주세요.")
        }
        /// 클로저, 리스너
    }
}

// MARK: - 테이블뷰 관련

extension MyClassVC: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classItems.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == classItems.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "add")! as! PlusTableViewCell
            if (userType == "teacher"){
                cell.isHidden = false
                cell.messageLabel.text = "학생 등록하기"
                cell.plusImage.image = UIImage(systemName: "plus")
                return cell
            } else if (userType == "student"){
                if (classItems.count == 0){
                    cell.messageLabel.text = "등록된 수업이 없습니다."
                    cell.plusImage.removeFromSuperview()
                } else {
                    cell.isHidden = true
                }
                return cell
            } else {
                cell.isHidden = true
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "class")! as! CardTableViewCell
            
            let item:ClassItem = classItems[indexPath.row]
            
            if (self.type == "teacher") {
                cell.studentName.text = "\(item.name) 학생"
                
            } else {
                cell.studentName.text = "\(item.name) 선생님"
            }
            cell.manageBtn.titleLabel!.text = "수업 바로가기"
            cell.subjectName.text = item.subject
            cell.subjectGoal.text = item.goal
            cell.cntLb.text = "\(item.currentCnt) / \(item.totalCnt)"
            cell.recentDate.text = "\(item.recentDate)"
            
            cell.manageBtn.addTarget(self, action: #selector(onClickManageButton(_:)), for: .touchUpInside)
            cell.manageBtn.tag = item.index
            
            return cell
        }
    }
    
    
    /// 수업관리하기 버튼 클릭
    /// - Parameter sender: 버튼
    @IBAction func onClickManageButton(_ sender: UIButton) {
        myClassDB.MoveToDetailClassVC(self: self, sender: sender)
        print("클릭됨 : \(sender.tag)")
    }
    
    /// didDelectRowAt: 셀 전체 클릭
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 플러스 row
        if indexPath.row == classItems.count {
            if (userType == "teacher"){
            performSegue(withIdentifier: "addStudentSegue", sender: nil)
            }
        }
        // 학생 row
        else {
            // 아무것도 하지 않음
        }
    }
}

// MARK: - 학생 추가 후 처리

extension MyClassVC: AddStudentDelegate {
    /// 학생 추가가 완료된 경우
    func onSuccess() {
        myClassDB.SetMyClasses(self: self)
    }
    
}
