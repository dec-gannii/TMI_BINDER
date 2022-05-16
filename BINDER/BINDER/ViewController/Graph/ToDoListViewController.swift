//
//  ToDoListViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/16.
//

import UIKit
import Firebase

public class ToDoListViewController: UIViewController {
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var userIndex: Int!
    var todos = Array<String>()
    var todoCheck = Array<Bool>()
    var todoDoc = Array<String>()
    var checkTime: Bool!
    var teacherUid: String!
    var studentName: String!
    var studentEmail: String!
    
    func _init(){
        userEmail = ""
        userSubject = ""
        userName = ""
        userType = ""
        userIndex = 0
        todos = []
        todoCheck = []
        todoDoc = []
        checkTime = false
        teacherUid = ""
        studentName = ""
        studentEmail = ""
    }
    
    @IBOutlet weak var todoTF: UITextField!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var plusBtn: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        GetUserInfoInDetailClassVC(self: nil, detailClassVC: nil, graphVC: nil, todolistVC: self)
        if self.userType == "student" {
            self.plusBtn.isHidden = true
            self.todoTF.isHidden = true
        } else {
            self.plusBtn.isHidden = false
        }
        self.todoTableView.reloadData()
        print ("TODO ::::: userName : \(userName) / userEmail : \(userEmail) / userIndex : \(userIndex) / userType : \(userType) / userSubject : \(userSubject)")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        guard let myClassDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassDetailViewController") as? MyClassDetailViewController else { return }
//        GetUserInfoInDetailClassVC(self: myClassDetailVC, detailClassVC: nil, graphVC: nil, todolistVC: self)
        super.viewWillAppear(true)
    }
    
    @IBAction func goButtonClicked(_ sender: Any) {
        if todoTF.text != "" {
            todos.append(todoTF.text ?? "")
            todoCheck.append(false)
            todoDoc = []
            AddToDoListFactors(self: self, checkTime: false)
            self.todoTableView.reloadData()
        }
    }
}

extension ToDoListViewController:UITableViewDataSource, UITableViewDelegate {
    
    //데이터 카운트
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    // 데이터 나타내기
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as! Todocell
        let todo = self.todos[indexPath.row]
        
        cell.todoLabel.text = "\(todo)"
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(checkMarkButtonClicked(sender:)),for: .touchUpInside)
        
        cell.checkButton.isSelected = todoCheck[indexPath.row]
        cell.checkButton.layer.cornerRadius = cell.checkButton.frame.size.width / 2
        cell.checkButton.layer.masksToBounds = true
        if cell.checkButton.isSelected == true {
            cell.checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
        return cell
    }
    
    // 데이터 삭제
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        DeleteToDoList(self: self, editingStyle: editingStyle, tableView: tableView, indexPath: indexPath)
    }
    
    // 투두리스트 선택에 따라
    @objc func checkMarkButtonClicked(sender: UIButton){
        if sender.isSelected{
            sender.isSelected = false
            checkTime = false
            //체크 내용 업데이트
            sender.setImage(UIImage(systemName: "square"), for: .normal)
        } else {
            sender.isSelected = true
            checkTime = true
            // 체크 내용 업데이트
            sender.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
        CheckmarkButtonClicked(self: self, checkTime: checkTime, sender: sender)
    }
}
