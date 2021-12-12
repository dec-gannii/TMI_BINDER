//
//  QuestionViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/11.
//

import UIKit

class QuestionViewController: BaseVC {
    
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    
    @IBOutlet weak var questionTV: UITableView!
    
    var questionItems: [QuestionItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    func getUserInfo(){
        LoginRepository.shared.doLogin {
                    /// 가져오는 시간 걸림
                    self.teacherName.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
                    self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
                    
                    //let url = URL(string: LoginRepository.shared.teacherItem!.profile)
                    //self.teacherImage.kf.setImage(with: url)
                    //self.teacherImage.makeCircle()
                    
                    /// 클래스 가져오기
                    //self.setMyClasses()
                } failure: { error in
                    self.showDefaultAlert(msg: "")
                }
                /// 클로저, 리스너
    }
    
    /// 질문 셋팅

    
    // 내 수업 가져오기
    func setMyClasses() {
                
        /// UITableView를 reload 하기
        self.questionTV.reloadData()
    }
        
    
}

// MARK: - 테이블뷰 관련

extension QuestionViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "add")! as! PlusTableViewCell
        return cell
//        if indexPath.row == questionItems.count {
//
//        }
//        else {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionViewController")! as! CardTableViewCell
//
//            let item:ClassItem = classItems[indexPath.row]
//            cell.studentName.text = "\(item.name) 학생 "
//            cell.subjectName.text = item.subject
//            cell.subjectGoal.text = item.goal
//            cell.cntLb.text = "\(item.currentCnt) / \(item.totalCnt)"
//
//            cell.classColor.makeCircle()
//            if let hex = Int(item.circleColor, radix: 16) {
//                cell.classColor.backgroundColor = UIColor.init(rgb: hex)
//            } else {
//                cell.classColor.backgroundColor = UIColor.red
//            }
//
//            cell.manageBtn.addTarget(self, action: #selector(onClickManageButton(_:)), for: .touchUpInside)
//            cell.manageBtn.tag = indexPath.row
//
//            return cell
//        }
    }
    
    
    /// 수업관리하기 버튼 클릭
    /// - Parameter sender: 버튼
    @IBAction func onClickManageButton(_ sender: UIButton) {
        let weekendVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController")
        weekendVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        weekendVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        
        self.present(weekendVC!, animated: true, completion: nil)
    }
    
    /// didDelectRowAt: 셀 전체 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 플러스 row
//        if indexPath.row == questionItems.count {
//            performSegue(withIdentifier: "addStudentSegue", sender: nil)
//        }
//        // 학생 row
//        else {
//            // 아무것도 하지 않음
//        }
    }
}
