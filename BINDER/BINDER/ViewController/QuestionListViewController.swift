//
//  QuestionListViewController.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import UIKit
import Kingfisher
import Firebase

class QuestionListViewController : BaseVC {
    
    // 네비게이션바
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var answeredToggle: UISwitch!
    
    @IBAction func stateChange(_ sender: UISwitch) {
//        if 토글 클릭 >  return answeredCheck 테이블
//        else return 전체 테이블뷰
    }
    
    // 테이블 뷰 연결
    @IBOutlet weak var questionListTV: UITableView!
    
    weak var delegate: QuestionListViewDelegate?
    
    var questionListItems: [QuestionListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setQuestionList()
        stateChange(answeredToggle)
    }
    
    /// 질문방 내용 세팅
    // 질문 리스트 가져오기
    func setQuestionList() {
        let db = Firestore.firestore()
        db.collection("student").document(Auth.auth().currentUser!.uid).collection("questionList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                
                /// 조회하기 위해 원래 있던 것 들 다 지움
                self.questionListItems.removeAll()
                
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let classDt = document.data()
                    
                    /// nil값 처리
                    let title = classDt["title"] as? String ?? ""
                    let answerCheck = classDt["answerCheck"] as? Bool ?? false
                    let questionContent = classDt["questionContent"] as? String ?? ""
                    let imgURL = classDt["imgURL"] as? String ?? ""
                    let email = classDt["email"] as? String ?? ""
                    let item = QuestionListItem(title: title, answerCheck: answerCheck, imgURL: imgURL as! String, questionContent: questionContent, email: email as! String)
                    
                    /// 모든 값을 더한다.
                    self.questionListItems.append(item)
                }
                
                /// UITableView를 reload 하기
                self.questionListTV.reloadData()
            }
        }
    }
    
}
extension QuestionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return questionListItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item:QuestionListItem = questionListItems[indexPath.row]
        
        if item.imgURL == nil {     // 기본 셀일 경우

            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionListTableViewCell
            cell.title.text = "\(item.title)"
            cell.questionContent.text = "\(item.questionContent)"
            
            if item.answerCheck == false {
                cell.answerCheck.text = "답변 대기"
                cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
            } else {
                // 오류 발생 지점(부동 소숫점 오류)
                cell.answerCheck.text = "답변 완료"
                cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
            }
                
            return cell

        } else {       // 이미지 셀일 경우

            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell

            cell.title.text = "\(item.title)"
            cell.questionContent.text = "\(item.questionContent)"
            
            let url = URL(string: item.imgURL)
            cell.questionImage.kf.setImage(with: url, placeholder: UIImage(systemName: "questionImage.fill"), options: nil, completionHandler: nil)
            
            if item.answerCheck == false {
                cell.answerCheck.text = "답변 대기"
                cell.background.backgroundColor = UIColor.init(red: 19, green: 32, blue: 62, alpha: 1)
            } else {
                cell.answerCheck.text = "답변 완료"
                cell.background.backgroundColor = UIColor.init(red: 148, green: 156, blue: 170, alpha: 1)
            }

            return cell
        }
    }
}
