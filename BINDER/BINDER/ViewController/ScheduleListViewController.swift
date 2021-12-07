//
//  ScheduleListViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/04.
//

import UIKit
import Firebase

class ScheduleListViewController: UIViewController {
    
    @IBOutlet weak var scheduleListTableView: UITableView!
    
    var date: String = ""
    var scheduleTitles: [String] = []
    var scheduleMemos: [String] = []
    var count: Int = 0
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        ref.keepSynced(true)
        
        let queue = DispatchQueue.global()
        queue.sync {
            let db = Firestore.firestore()
            let docRef = db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date)
            
            docRef.whereField("Date", isEqualTo: self.date).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let scheduleTitle = document.data()["Title"] as? String ?? ""
                        let scheduleMemo = document.data()["Memo"] as? String ?? ""
                        self.scheduleTitles.append(scheduleTitle)
                        self.scheduleMemos.append(scheduleMemo)
                        
                        self.count = self.scheduleTitles.count
                        print("===count==== \(self.count)")
                    }
                }
            }
        }
        scheduleListTableView.delegate = self
        scheduleListTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.scheduleListTableView.beginUpdates()
        self.scheduleListTableView.reloadData()
        self.scheduleListTableView.endUpdates()
    }
    
    @IBAction func EditButtonClicked(_ sender: Any) {
        guard let editScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        editScheduleVC.date = self.date
        editScheduleVC.isEditingMode = true
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        self.present(editScheduleVC, animated: true, completion: nil)
    }
    
    @IBAction func AddButtonClicked(_ sender: Any) {
        guard let editScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        editScheduleVC.date = self.date
        editScheduleVC.isEditingMode = false
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        self.present(editScheduleVC, animated: true, completion: nil)
    }
}

extension ScheduleListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleCell = scheduleListTableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCellTableViewCell
        
        scheduleCell.scheduleDate.text = self.date
        
        for i in 0...(scheduleTitles.count-1) {
            scheduleCell.scheduleTitle.text = scheduleTitles[i]
            scheduleCell.scheduleMemo.text = scheduleMemos[i]
        }
        
        self.scheduleListTableView.reloadData()
        self.scheduleListTableView.beginUpdates()
        self.scheduleListTableView.reloadRows(at: self.scheduleListTableView.indexPathsForVisibleRows!, with: .none)
        self.scheduleListTableView.endUpdates()
        
        return scheduleCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count : " + "\(self.count)")
        return self.count
    }
    
}
