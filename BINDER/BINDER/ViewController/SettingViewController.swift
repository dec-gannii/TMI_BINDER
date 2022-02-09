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
    
    var tableViewItems = ["정보수정", "이용약관"]
    var tableViewSections = ["설정"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.dataSource = self
        settingTableView.delegate = self
    }
    
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SettingViewController: UIViewControllerTransitioningDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableViewItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (indexPath.row == 0) {
            guard let checkpwVC = self.storyboard?.instantiateViewController(withIdentifier: "CheckPasswordViewController") as? CheckPasswordViewController else { return }
//            self.navigationViewController?.pushViewController(checkpwVC, animated: true)
            checkpwVC.modalPresentationStyle = .fullScreen
            checkpwVC.modalTransitionStyle = .crossDissolve
//            self.navigationController?.pushViewController(checkpwVC, animated: true)
            self.present(checkpwVC, animated: true, completion: nil)
            
        }
    }
    
    
}
