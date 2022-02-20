//
//  ScheduleListViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/04.
//

import UIKit
import Firebase

// 일정 리스트 뷰 컨트롤러
class ScheduleListViewController: UIViewController {
    
    @IBOutlet weak var scheduleListTableView: UITableView!
    
    var date: String = ""
    var scheduleTitles: [String] = []
    var scheduleMemos: [String] = []
    var count: Int = 0
    var selectedTitle: String = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleListTableView.delegate = self
        scheduleListTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scheduleListTableView.reloadData()
    }
    
    // 일정 추가 버튼 (+) 클릭 시 사용되는 메소드
    @IBAction func AddButtonClicked(_ sender: Any) {
        guard let addScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        addScheduleVC.date = self.date // 날짜 정보를 넘겨주기
        addScheduleVC.modalPresentationStyle = .fullScreen
        self.present(addScheduleVC, animated: true, completion: nil)
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ScheduleListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleCell = scheduleListTableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCellTableViewCell
        
        // 데이터베이스에서 일정 리스트 가져오기
        let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList")
//        self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date)
        // Date field가 현재 날짜와 동일한 도큐먼트 모두 가져오기
        print (self.date)
        docRef.whereField("date", isEqualTo: self.date).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 사용할 것들 가져와서 지역 변수로 저장
                    let scheduleTitle = document.data()["title"] as? String ?? ""
                    let scheduleMemo = document.data()["memo"] as? String ?? ""
                    
                    print ("scheduleTitle : \(scheduleTitle), scheduleMemo : \(scheduleMemo)")
                    
                    if (!self.scheduleTitles.contains(scheduleTitle)) {
                        // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                        self.scheduleTitles.append(scheduleTitle)
                        print(scheduleTitle)
                        self.scheduleMemos.append(scheduleMemo)
                    }
                    
                    // 가져온 내용들을 순서대로 일정 셀의 텍스트로 설정
                    scheduleCell.scheduleTitle.text = self.scheduleTitles[indexPath.row]
                    scheduleCell.scheduleMemo.text = self.scheduleMemos[indexPath.row]
                    // 일정의 제목은 필수 항목이므로 일정 제목 개수만큼을 개수로 지정
                    self.count = self.scheduleTitles.count
                }
            }
        }
        // 날짜는 선택된 날짜로 고정되도록 설정
        scheduleCell.scheduleDate.text = self.date
        
        return scheduleCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count // 셀의 개수 반환
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀이 선택되면 수정될 수 있도록 설정
        guard let editScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        editScheduleVC.date = self.date // 선택된 날짜 데이터 전달
        editScheduleVC.editingTitle = scheduleTitles[indexPath.row] // 선택된 셀의 일정 제목 데이터 전달
        editScheduleVC.modalPresentationStyle = .fullScreen
        self.present(editScheduleVC, animated: true, completion: nil)
    }
    
    // 일정 삭제를 위한 메소드 - 1
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { return .delete }
    
    // 일정 삭제를 위한 메소드 - 2
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedTitle = scheduleTitles[indexPath.row]
        if editingStyle == .delete {
//            self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date)
            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList").document(selectedTitle).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.count = self.count - 1
                    self.scheduleListTableView.reloadData()
                }
            }
            
            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList").getDocuments()
            {
                (querySnapshot, err) in
                
                if let err = err
                {
                    print("Error getting documents: \(err)");
                }
                else
                {
                    var count = 0
                    for document in querySnapshot!.documents {
                        count += 1
                        print("\(document.documentID) => \(document.data())");
                    }
                    
                    if (count == 1) {
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList").document("Count").setData(["count": 0])
                        { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    } else {
                        self.db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("schedule").document(self.date).collection("scheduleList").document("Count").setData(["count": count-1])
                        { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                }
            }
        }
    }
}
