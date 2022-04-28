//
//  ParentHomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import Firebase
import FirebaseFirestore


// 학부모 버전 Home 화면
class ParentHomeViewController: UIViewController {
    var evaluationItem: [EvaluationItem] = [] // 평가 항목 저장할 EvaluationItem 배열
    var teacherEmails: [String] = []
    var teacherNames: [String] = []
    
    var studentUid: String = "" // db 접근을 위해 필요한 학생 uid 정보
    var teacherName = "" // 선생님 이름
    var teacherEmail = "" // 선생님 이메일
    var subject = "" // 과목
    var selectedMonth = "" // 선택된 달
    let nowDate = Date() // 오늘 날짜
    
    @IBOutlet weak var parentNameLabel: UILabel! // 학부모 이름 Label
    @IBOutlet weak var progressListTableView: UITableView! // TableView
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView 관련 delegate, dataSource 처리
        progressListTableView.delegate = self
        progressListTableView.dataSource = self
        
        setEvaluation() // 평가 불러오기
        getUserInfo() // 사용자 정보 받아오기
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM" // MM월의 형태로 설정
        self.selectedMonth = dateFormatter.string(from: self.nowDate) + "월" // MM월의 형태로 선택된 달 변수에 저장
        
        // TableView 분리선 없애기
        progressListTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        progressListTableView.reloadData() // 평가가 나타나는 tableview 그리기
    }
    
    // DB에서 사용자 정보 가져오기
    func getUserInfo() {
        let db = Firestore.firestore()
        // parent collection에서 현재 로그인한 uid와 같은 uid 정보를 가지는 문서 찾기
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                if let err = err {
                    print("Error getting documents(inMyClassView): \(err)")
                } else {
                    /// 문서 존재하면
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        // 이름 받아서 학부모 이름 label의 text를 'OOO 학부모님'으로 지정
                        
                        let name = document.data()["name"] as? String ?? ""
                        self.parentNameLabel.text = name + " 학부모님"
                    }
                }
            }
        }
//        setEvaluation()
    }
    
    // 평가 불러오기
    func setEvaluation() {
        self.teacherEmails.removeAll()
        self.teacherNames.removeAll()
        
        let db = Firestore.firestore()
        // parent collection에서 현재 로그인한 uid와 같은 uid 정보를 가지는 문서 찾기
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                /// nil이 아니면
                /// 문서 존재하면
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    // 등록된 자녀 휴대폰 번호를 가져와서
                    let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                    
                    // student collection에서 가져온 휴대폰 번호와 같은 본인 휴대폰 번호 정보를 가지는 문서 찾기
                    db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let studentUid = document.data()["uid"] as? String ?? "" // 학생 uid 정보
                                self.studentUid = studentUid // self.studentUid 변수에도 저장해주기
                                
                                // 클래스 정보를 가져오기 위해서 고정으로 설정된 8번의 횟수를 이용해 class 모두 찾기
                                db.collection("student").document(studentUid).collection("class").whereField("totalCnt", isEqualTo: 8).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        /// 조회하기 위해 원래 있던 것 들 다 지움
                                        self.evaluationItem.removeAll()
                                        
                                        for document in querySnapshot!.documents {
                                            let evaluationData = document.data()
                                            
                                            let name = evaluationData["name"] as? String ?? "" // 선생님 이름
                                            self.teacherName = name
                                            self.teacherNames.append(name)
                                            let email = evaluationData["email"] as? String ?? "" // 선생님 이메일
                                            self.teacherEmail = email
                                            self.teacherEmails.append(email)
                                            let subject = evaluationData["subject"] as? String ?? "" // 과목
                                            self.subject = subject
                                            let currentCnt = evaluationData["currentCnt"] as? Int ?? 0 // 현재 횟수
                                            let totalCnt = evaluationData["totalCnt"] as? Int ?? 8 // 총 횟수
                                            let evaluation = evaluationData["evaluation"] as? String ?? "선택된 달이 없습니다." // 평가 내용
                                            let circleColor = evaluationData["circleColor"] as? String ?? "026700" // 원 색상
                                            
                                            let item = EvaluationItem(email: email, name: name, evaluation: evaluation, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: circleColor, subject: subject)
                                            
                                            self.evaluationItem.append(item) // evaluationItem 배열에 append 해주기
                                        }
                                    }
                                }
                            }
                        }
                        /// UITableView를 reload 하기
                        self.progressListTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension ParentHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // tableview에 표시될 cell 개수 반환
        print ("evaluationItem.count : \(evaluationItem.count)")
        return evaluationItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableview에 표시될 cell type : StudentEvaluationCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentEvaluationCell", for: indexPath) as! StudentEvaluationCell
        // cell에서 db를 연결해서 가져와야할 정보가 studentUid가 필요한 정보이므로 cell의 변수에 넘겨주기
        cell.studentUid = self.studentUid
        
        // 배열의 요소를 가져와서 item이라는 EvaluationItem 타입의 item으로 선언
        let item:EvaluationItem = evaluationItem[indexPath.row]
        
        cell.setTeacherInfo(item.name, item.email, item.subject) // cell의 함수를 이용해서 수업의 정보 넘기기
        cell.subjectLabel.text = item.subject + " - " + item.name + " 선생님" // 과목과 선생님의을 보여주는 label의 text로 지정
        cell.progressLabel.text = "\(item.currentCnt) / \(item.totalCnt)" // 수업의 현재 횟수 / 전체 횟수 지정
        cell.monthlyEvaluationTextView.text = item.evaluation // 평가 항목을 item의 평가 항목 text로 지정
        cell.classColorView.makeCircle() // 수업 색상을 지정하는 view를 원으로 보이도록 설정
        if let hex = Int(item.circleColor, radix: 16) { // 16진수로 저장된 string을 int로 바꿔주어 hex에 넣어주기
            cell.classColorView.backgroundColor = UIColor.init(rgb: hex) // 있으면 그 hex로 컬러 설정
        } else {
            cell.classColorView.backgroundColor = UIColor.red // 없으면 기본적으로 빨간색으로 설정
        }
        
        // cell의 더보기 버튼을 클릭하면 onClickShowDetailButton 함수 실행되도록 설정
        cell.showMoreInfoButton.addTarget(self, action: #selector(onClickShowDetailButton(_:)), for: .touchUpInside)
        cell.showMoreInfoButton.tag = indexPath.row // tag를 현재 indexPath.row로 설정
        
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
