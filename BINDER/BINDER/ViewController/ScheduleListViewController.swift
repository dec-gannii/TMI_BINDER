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
    var selectedTitle: String = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleListTableView.delegate = self
        scheduleListTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.scheduleListTableView.reloadData()
    }
    
    @IBAction func AddButtonClicked(_ sender: Any) {
        guard let addScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        addScheduleVC.date = self.date
        self.present(addScheduleVC, animated: true, completion: nil)
    }
}

extension ScheduleListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let scheduleCell = scheduleListTableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCellTableViewCell
        
        let docRef = self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date)
        
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
                    
                    scheduleCell.scheduleTitle.text = self.scheduleTitles[indexPath.row]
                    scheduleCell.scheduleMemo.text = self.scheduleMemos[indexPath.row]
                    
                    self.count = self.scheduleTitles.count
                }
            }
        }
        
        scheduleCell.scheduleDate.text = self.date
        //        scheduleCell.selectionStyle = .none
        return scheduleCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count : " + "\(self.count)")
        return self.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let editScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        editScheduleVC.date = self.date
        editScheduleVC.editingTitle = scheduleTitles[indexPath.row]
        self.present(editScheduleVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { return .delete }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedTitle = scheduleTitles[indexPath.row]
        if editingStyle == .delete {
            //            scheduleTitles.remove(at: indexPath.row)
            //            scheduleMemos.remove(at: indexPath.row)
            //            scheduleListTableView.deleteRows(at: [indexPath], with: .fade)
            
            
            self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document(selectedTitle).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(date).getDocuments()
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
                        self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document("Count").setData(["count": count])
                        { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    } else {
                        self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document("Count").setData(["count": count-1])
                        { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                    print("Count = \(count)");
                }
            }
        }
    }
}
