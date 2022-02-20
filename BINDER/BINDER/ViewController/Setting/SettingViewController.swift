//
//  SettingViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/09.
//

import UIKit
import Firebase

class SettingViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    var tableViewItems = ["정보수정", "이용약관", "서비스 탈퇴"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.dataSource = self
        settingTableView.delegate = self
    }
    
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingViewController: UIViewControllerTransitioningDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableViewItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            guard let checkpwVC = self.storyboard?.instantiateViewController(withIdentifier: "CheckPasswordViewController") as? CheckPasswordViewController else { return }
            checkpwVC.modalPresentationStyle = .fullScreen
            checkpwVC.modalTransitionStyle = .crossDissolve
            self.present(checkpwVC, animated: true, completion: nil)
        } else if (indexPath.row == 1) {
            guard let termVC = self.storyboard?.instantiateViewController(withIdentifier: "TermViewController") as? TermViewController else { return }
            termVC.modalPresentationStyle = .fullScreen
            termVC.modalTransitionStyle = .crossDissolve
            self.present(termVC, animated: true, completion: nil)
        } else if (indexPath.row == 2) {
            guard let termVC = self.storyboard?.instantiateViewController(withIdentifier: "SecessionViewController") as? SecessionViewController else { return }
            termVC.modalPresentationStyle = .fullScreen
            termVC.modalTransitionStyle = .crossDissolve
            self.present(termVC, animated: true, completion: nil)
        }
    }
    
    
}
