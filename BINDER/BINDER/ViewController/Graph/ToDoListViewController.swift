//
//  ToDoListViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/15.
//

import UIKit

public class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var toDoTF: UITextField!
    @IBOutlet weak var toDoListTableView: UITableView!
    @IBOutlet weak var plusBtn: UIButton!
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var userIndex: Int!
    var studentName: String!
    var studentEmail: String!
    var teacherUid: String!
    
    var todos = Array<String>()
    var todoCheck = Array<Bool>()
    var todoDoc = Array<String>()
    var checkTime: Bool!
    
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
        studentName = ""
        studentEmail = ""
        teacherUid = ""
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func AddToDoBtnClicked(_ sender: Any) {if toDoTF.text != "" {
        todos.append(toDoTF.text ?? "")
        todoCheck.append(checkTime)
        todoDoc = []
        AddToDoListFactors(self: self, checkTime: checkTime)
        toDoTF.text = ""
        self.toDoListTableView.reloadData()
    }
    }
}

extension ToDoListViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            cell.checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
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
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            sender.isSelected = true
            checkTime = true
            // 체크 내용 업데이트
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        }
        CheckmarkButtonClicked(self: self, checkTime: checkTime, sender: sender)
    }
}
