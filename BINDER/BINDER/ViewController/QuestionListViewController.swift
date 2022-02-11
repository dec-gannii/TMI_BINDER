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
    
    // 테이블 뷰 연결
    @IBOutlet weak var questionListTV: UITableView!
    
    var questionListItems: [QuestionListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    let subjectName = classDt["subjectName"] as? String ?? ""
                    let answerCheck = classDt["answerCheck"] as? Bool ?? false
                    let questionContent = classDt["questionContent"] as? String ?? ""
                    let imgURL = classDt["imgURL"]
                    let email = classDt["email"]
                    let item = QuestionListItem(subjectName: subjectName, answerCheck: answerCheck, imgURL: imgURL as! String, questionContent: questionContent, email: email as! String)
                    
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
        
        if imgURL == nil {

            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")! as! QuestionTableViewCell
            return cell

        } else {

            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")! as! QuestionListTableViewImageCell

//            let item:ClassItem = classItems[indexPath.row]
//            cell.studentName.text = "\(item.name) 학생 "
//            cell.subjectName.text = item.subject
//            cell.subjectGoal.text = item.goal
//            cell.cntLb.text = "\(item.currentCnt) / \(item.totalCnt)"
//            cell.recentDate.text = "최근 수업 : \(item.recentDate)"
//            cell.classColor.makeCircle()
//            if let hex = Int(item.circleColor, radix: 16) {
//                cell.classColor.backgroundColor = UIColor.init(rgb: hex)
//            } else {
//                cell.classColor.backgroundColor = UIColor.red
//            }
//
//            cell.manageBtn.addTarget(self, action: #selector(onClickManageButton(_:)), for: .touchUpInside)
//            cell.manageBtn.tag = indexPath.row

            return cell
        }
    }
}
