//
//  QuestionListViewController.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import UIKit
import Kingfisher
import Firebase

public class QuestionListViewController : BaseVC {
    
    let db = Firestore.firestore()
    var docRef : CollectionReference!
    
    // 네비게이션바
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var toggleLabel: UILabel!
    // 뒤로가기 버튼
    @IBOutlet var backbutton: UIView!
    @IBOutlet weak var plusbutton: UIBarButtonItem!
    // 토글
    @IBOutlet weak var answeredToggle: UISwitch!
    // 테이블 뷰 연결
    @IBOutlet weak var questionListTV: UITableView!
    
    @IBAction func clickBackbutton(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func answeredToggleAction(_ sender: Any) {
        setQuestionList()
    }
    
    // 값을 받아오기 위한 변수들
    var name : String!
    var subject : String!
    var email : String!
    var answerCheck : Bool!
    var sname: String!
    var type = ""
    var index : Int!
    var qnum: Int!
    var maxnum = 0
    var teacherUid: String!
    var questionListItems : [QuestionListItem] = []
    var questionAnsweredItems : [QuestionAnsweredListItem] = []
    var questionNotAnsweredItems : [QuestionAnsweredListItem] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        answeredToggle.setOn(false, animated: true)
        
        GetUserInfoInQuestionView(toggleLabel: self.toggleLabel, index: self.index, navigationBar: self.navigationBar, navigationBarItem: self.navigationBarItem, self: self)
        
        self.questionListTV.reloadData()
        
        if (userName != nil) { // 사용자 이름이 nil이 아닌 경우
            if (userType == "student") { // 사용자가 학생이면
                self.navigationBar.topItem!.title = userName + " 선생님"
                self.toggleLabel.text = "답변 완료만 보기"
            } else { // 사용자가 학생이 아니면(선생님이면)
                self.navigationBar.topItem!.title = userName + " 학생"
                self.toggleLabel.text = "답변 대기만 보기"
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        answeredToggle.setOn(false, animated: true)
        
        GetUserInfoInQuestionView(toggleLabel: self.toggleLabel, index: self.index, navigationBar: self.navigationBar, navigationBarItem: self.navigationBarItem, self: self)
        
        self.questionListTV.reloadData()
        
        if (userName != nil) { // 사용자 이름이 nil이 아닌 경우
            if (userType == "student") { // 사용자가 학생이면
                self.navigationBar.topItem!.title = userName + " 선생님"
                self.toggleLabel.text = "답변 완료만 보기"
            } else { // 사용자가 학생이 아니면(선생님이면)
                self.navigationBar.topItem!.title = userName + " 학생"
                self.toggleLabel.text = "답변 대기만 보기"
            }
        }
    }
    
    func setTeacherQuestion() {
        LoginRepository.shared.doLogin {
            /// 클래스 가져오기
            self.setQuestionList()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    func setStudentQuestion() {
        LoginRepository.shared.doLogin {
            /// 클래스 가져오기
            self.setQuestionList()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    /// 질문방 내용 세팅
    // 질문 리스트 가져오기
    func setQuestionList() {
        SetQuestionList(self: self)
        questionListTV.reloadData()
        return
    }
    
    @IBAction func clickPlusBtn(_ sender: Any) {
        guard let plusVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionPlusVC") as? QuestionPlusViewController else { return }
        
        plusVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        plusVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        /// first : 여러개가 와도 첫번째 것만 봄.
        
        plusVC.qnum = maxnum + 1
        plusVC.index = index
        plusVC.email = userEmail
        plusVC.userName = userName
        plusVC.type = userType
        plusVC.subject = userSubject
        
        self.present(plusVC, animated: true, completion: nil)
    }
}




// MARK: - 테이블 뷰 관련

extension QuestionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (userType == "teacher") {
            if (answeredToggle.isOn) {
                return self.questionNotAnsweredItems.count
            } else {
                return self.questionListItems.count
            }
        } else {
            if (answeredToggle.isOn) {
                return self.questionAnsweredItems.count
            } else {
                return self.questionListItems.count
            }
        }
    }
    
    // 테이블뷰 선택시
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var qemail: String!
        
        if (self.answeredToggle.isOn){
            if type == "teacher" {
                // 답변 대기가 뜸
                let item = self.questionNotAnsweredItems[indexPath.row]
                
                guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionDetailVC") as? QuestionDetailViewController else { return }
                
                questionVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                questionVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                /// first : 여러개가 와도 첫번째 것만 봄.
                
                questionVC.qnum = Int(item.index)
                questionVC.email = qemail
                questionVC.type = userType
                questionVC.subject = userSubject
                questionVC.index = self.index
                
                self.present(questionVC, animated: true, completion: nil)
            } else {
                // 답변 완료가 뜸
                let item = self.questionAnsweredItems[indexPath.row]
                
                guard let qnaVC = self.storyboard?.instantiateViewController(withIdentifier: "QnADetailVC") as? QnADetailViewController else { return }
                
                qnaVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                qnaVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                /// first : 여러개가 와도 첫번째 것만 봄.
                
                qnaVC.qnum = Int(item.index)
                qnaVC.email = qemail
                qnaVC.type = userType
                qnaVC.subject = userSubject
                qnaVC.index = self.index
                
                self.present(qnaVC, animated: true, completion: nil)
                
            }
            
        } else {
            
            let item:QuestionListItem = self.questionListItems[indexPath.row]
            
            if item.answerCheck == true { //답변이 있는 경우
                guard let qnaVC = self.storyboard?.instantiateViewController(withIdentifier: "QnADetailVC") as? QnADetailViewController else { return }
                
                qnaVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                qnaVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                /// first : 여러개가 와도 첫번째 것만 봄.
                
                qnaVC.qnum = Int(item.index)
                qnaVC.email = qemail
                qnaVC.type = userType
                qnaVC.subject = userSubject
                qnaVC.index = self.index
                
                self.present(qnaVC, animated: true, completion: nil)
            }else { // 답변이 없는 경우
                guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionDetailVC") as? QuestionDetailViewController else { return }
                
                questionVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                questionVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                /// first : 여러개가 와도 첫번째 것만 봄.
                
                questionVC.qnum = Int(item.index)
                questionVC.email = qemail
                questionVC.type = userType
                questionVC.subject = userSubject
                questionVC.index = self.index
                
                self.present(questionVC, animated: true, completion: nil)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.answeredToggle.isOn) {
            if (userType == "student") {
                let item = self.questionAnsweredItems[indexPath.row]
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 완료"
                    cell.background.backgroundColor = UIColor.init(rgb: 0xE5E5E5)
                    cell.answerCheck.textColor = UIColor.init(rgb: 0xB3B2B9)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 완료"
                    cell.background.backgroundColor = UIColor.init(rgb: 0xE5E5E5)
                    cell.answerCheck.textColor = UIColor.init(rgb: 0xB3B2B9)
                    return cell
                }
            } else {
                let item = self.questionNotAnsweredItems[indexPath.row]
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 대기"
                    cell.background.backgroundColor = UIColor.init(rgb: 0xCDE7FC)
                    cell.answerCheck.textColor = UIColor.init(rgb: 0x0168FF)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    cell.answerCheck.text = "답변 대기"
                    cell.background.backgroundColor = UIColor.init(rgb: 0xCDE7FC)
                    cell.answerCheck.textColor = UIColor.init(rgb: 0x0168FF)
                    return cell
                }
            }
        } else {
            let item = self.questionListItems[indexPath.row]
            if (userType == "student") {
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xE5E5E5)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0xB3B2B9)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xCDE7FC)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0x0168FF)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xE5E5E5)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0xB3B2B9)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xCDE7FC)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0x0168FF)
                    }
                    return cell
                }
            } else {
                if (item.imgURL == "") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
                    cell.title.text = item.title
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xE5E5E5)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0xB3B2B9)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xCDE7FC)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0x0168FF)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell
                    cell.title.text = item.title
                    cell.questionImage.kf.setImage(with: URL(string: item.imgURL), placeholder: UIImage(systemName: "no image"), options: nil, completionHandler: nil)
                    cell.questionContent.text = "\(item.questionContent)"
                    if (item.answerCheck == true) {
                        cell.answerCheck.text = "답변 완료"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xE5E5E5)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0xB3B2B9)
                    } else {
                        cell.answerCheck.text = "답변 대기"
                        cell.background.backgroundColor = UIColor.init(rgb: 0xCDE7FC)
                        cell.answerCheck.textColor = UIColor.init(rgb: 0x0168FF)
                    }
                    return cell
                }
            }
        }
    }
}
