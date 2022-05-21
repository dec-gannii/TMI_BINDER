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
    var studentSubject: String!
    
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
    
    var functionShare = FunctionShare()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var textfields = [UITextField]()
        textfields = [self.todoTF]
        
        functionShare.textFieldPaddingSetting(textfields)
        /// 키보드 띄우기
        self.todoTF.becomeFirstResponder()
        
        GetUserInfoInDetailClassVC(self: nil, detailClassVC: nil, graphVC: nil, todolistVC: self)
        if self.userType == "student" {
            self.plusBtn.isHidden = true
            self.todoTF.isHidden = true
        } else {
            self.plusBtn.isHidden = false
        }
        self.todoTableView.reloadData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        guard let myClassDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassDetailViewController") as? MyClassDetailViewController else { return }
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
       
        if self.userType == "student"{
            cell.todoDelete.isHidden = true
        }
        
        cell.todoLabel.text = "\(todo)"
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(checkMarkButtonClicked(sender:)),for: .touchUpInside)
        
        cell.todoDelete.tag = indexPath.row
        cell.todoDelete.addTarget(self, action: #selector(deleteMarkButtonClicked(sender:)), for: .touchUpInside)
        
        cell.checkButton.isSelected = todoCheck[indexPath.row]
        cell.checkButton.layer.cornerRadius = cell.checkButton.frame.size.width / 2
        cell.checkButton.layer.masksToBounds = true
        if cell.checkButton.isSelected == true {
            cell.checkButton.setImage(UIImage(named: "checkbox_square_Checked"), for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(named: "checkbox_square_notChecked"), for: .normal)
        }
        return cell
    }
    
    //투두리스트 삭제에 따라
    @objc func deleteMarkButtonClicked(sender: UIButton){
        print("delete todo clicked")
        DeleteToDoList(self: self,sender: sender)
        self.todoTableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                // delete the item here
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
                deleteAction.backgroundColor = .systemGray
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }
    
    // 투두리스트 선택에 따라
    @objc func checkMarkButtonClicked(sender: UIButton){
        if sender.isSelected{
            sender.isSelected = false
            checkTime = false
            //체크 내용 업데이트
            sender.setImage(UIImage(named: "checkbox_square_notChecked"), for: .normal)
        } else {
            sender.isSelected = true
            checkTime = true
            // 체크 내용 업데이트
            sender.setImage(UIImage(named: "checkbox_square_Checked"), for: .normal)
        }
        CheckmarkButtonClicked(self: self, checkTime: checkTime, sender: sender)
    }
}
