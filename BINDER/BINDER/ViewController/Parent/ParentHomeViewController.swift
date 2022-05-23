//
//  ParentHomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseFirestore

// 학부모 버전 Home 화면

public class ParentHomeViewController: UIViewController {
    var evaluationItem: [EvaluationItem] = [] // 평가 항목 저장할 EvaluationItem 배열
    var teacherEmails: [String] = []
    var teacherNames: [String] = []
    var studentUid: String! // db 접근을 위해 필요한 학생 uid 정보
    var teacherName: String!// 선생님 이름
    var teacherEmail: String! // 선생님 이메일
    var subject: String! // 과목
    var selectedMonth: String! // 선택된 달
    let nowDate = Date() // 오늘 날짜
    
    @IBOutlet weak var parentNameLabel: UILabel! // 학부모 이름 Label
    @IBOutlet weak var progressListTableView: UITableView! // TableView
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        GetParentUserInfo(self: self) // 사용자 정보 받아오기
        setEvaluation() // 평가 불러오기
        updateFCM()
        
        // TableView 관련 delegate, dataSource 처리
        progressListTableView.delegate = self
        progressListTableView.dataSource = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM" // MM월의 형태로 설정
        self.selectedMonth = dateFormatter.string(from: self.nowDate) + "월" // MM월의 형태로 선택된 달 변수에 저장
        
        // TableView 분리선 없애기
        progressListTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        progressListTableView.reloadData() // 평가가 나타나는 tableview 그리기
    }
    
    func updateFCM(){
        let db = Firestore.firestore()
        
        db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
            "fcmToken": Messaging.messaging().fcmToken
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    // 평가 불러오기
    func setEvaluation() {
        self.teacherEmails.removeAll()
        self.teacherNames.removeAll()
        SetEvaluation(self: self)
    }
}

extension ParentHomeViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // tableview에 표시될 cell 개수 반환
        return evaluationItem.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableview에 표시될 cell type : StudentEvaluationCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentEvaluationCell", for: indexPath) as! StudentEvaluationCell
        // cell에서 db를 연결해서 가져와야할 정보가 studentUid가 필요한 정보이므로 cell의 변수에 넘겨주기
        cell.studentUid = self.studentUid
        
        // 배열의 요소를 가져와서 item이라는 EvaluationItem 타입의 item으로 선언
        let item:EvaluationItem = evaluationItem[indexPath.row]
        
        cell.setTeacherInfo(item.name, item.email, item.subject) // cell의 함수를 이용해서 수업의 정보 넘기기
        cell.subjectLabel.text = item.subject // 과목과 선생님의을 보여주는 label의 text로 지정
        cell.progressLabel.text = "\(item.currentCnt) / \(item.totalCnt)" // 수업의 현재 횟수 / 전체 횟수 지정
        cell.TeacherNameLabel.text = item.name + " 선생님" // 평가 항목을 item의 평가 항목 text로 지정
        
        // cell의 더보기 버튼을 클릭하면 onClickShowDetailButton 함수 실행되도록 설정
        cell.showMoreInfoButton.addTarget(self, action: #selector(onClickShowDetailButton(_:)), for: .touchUpInside)
        cell.showMoreInfoButton.tag = item.index // tag를 현재 indexPath.row로 설정
        
        self.selectedMonth = cell.selectedMonth // cell의 선택된 달을 현재의 self.selectedMonth 변수값을 넣어주기
        
        // 설정이 완료된 cell 반환
        return cell
    }
    
    @IBAction func onClickShowDetailButton(_ sender: UIButton) {
        // 더보기 버튼을 누르면 상세 페이지(detailEvaluationViewController)로 이동
        guard let detailEvaluationVC = self.storyboard?.instantiateViewController(withIdentifier: "ParentDetailEvaluationViewController") as? ParentDetailEvaluationViewController else {
            //아니면 종료
            return
        }
        
        detailEvaluationVC.modalTransitionStyle = .crossDissolve
        detailEvaluationVC.modalPresentationStyle = .fullScreen
        
        // detailEvaluationViewController에서 사용할 정보들 넘겨주기
        detailEvaluationVC.teacherEmail = self.teacherEmails[sender.tag]
        detailEvaluationVC.teacherName = self.teacherNames[sender.tag]
        detailEvaluationVC.subject = self.subject
        detailEvaluationVC.index = sender.tag
        detailEvaluationVC.month = self.selectedMonth
        
        // detailEvaluationViewController present
        self.present(detailEvaluationVC, animated: true)
        print("클릭됨 : \(sender.tag)")
    }
}
