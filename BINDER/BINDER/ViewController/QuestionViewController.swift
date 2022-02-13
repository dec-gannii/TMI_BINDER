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

class QuestionViewController: BaseVC {
    
    // 요소 연결(테이블 뷰 관)
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    
    // 테이블 뷰 연결
    @IBOutlet weak var questionTV: UITableView!
    
    // 값을 넘기기 위한 Delegate
    weak var delegate: QuestionListViewDelegate?
    
    var questionItems: [QuestionItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    func getUserInfo(){
        LoginRepository.shared.doLogin {
            self.teacherName.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
            self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
            
            let url = URL(string: LoginRepository.shared.teacherItem!.profile)
//            let url = Auth.auth().currentUser?.photoURL
            self.teacherImage.kf.setImage(with: url)
            self.teacherImage.makeCircle()
            
            self.setQuestionroom()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
    }
    
    /// 질문방 내용 세팅
    // 내 수업 가져오기
    func setQuestionroom() {
        let db = Firestore.firestore()
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                
                /// 조회하기 위해 원래 있던 것 들 다 지움
                self.questionItems.removeAll()
                
                
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let classDt = document.data()
                    
                    /// nil값 처리
                    let name = classDt["name"] as? String ?? ""
                    let subject = classDt["subject"] as? String ?? ""
                    let classColor = classDt["circleColor"] as? String ?? "026700"
                    let email = classDt["email"] as? String ?? ""
                    let item = QuestionItem(studentName : name, subjectName : subject, classColor: classColor, email: email)
                    
                    /// 모든 값을 더한다.
                    self.questionItems.append(item)
                }
                
                /// UITableView를 reload 하기
                self.questionTV.reloadData()
            }
        }
    }
    
}


// MARK: - 테이블뷰 관련

extension QuestionViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "question")! as! QuestionTableViewCell
        
        let item:QuestionItem = questionItems[indexPath.row]
        cell.studentName.text = "\(item.studentName) 학생"
        cell.subjectName.text = item.subjectName
        //print(item.subjectName)
        cell.classColor.allRoundSmall()
        if let hex = Int(item.classColor, radix: 16) {
            cell.classColor.backgroundColor = UIColor.init(rgb: hex)
        } else {
            cell.classColor.backgroundColor = UIColor.red
        }
        
        return cell
        
    }
    
    /// didDelectRowAt: 셀 전체 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    /// segue를 호출할 때, 데이터를 넘기고 싶은 경우에 사용
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // delegate 전달
        if let resultVC = segue.destination as? QuestionListViewController {
            //resultVC.delegate = self
        }
        
    }
}
