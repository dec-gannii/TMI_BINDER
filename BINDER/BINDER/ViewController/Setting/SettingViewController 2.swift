//
//  SettingViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/02/09.
//
// 설정 화면 뷰 컨트롤러

import UIKit
import Firebase

class SettingViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    // 설정에 들어갈 메뉴들의 title (tableview에 들어갈 것)
    var tableViewItems = ["정보수정", "이용약관", "서비스 탈퇴"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.dataSource = self
        settingTableView.delegate = self
    }
    
    // 뒤로 가기 버튼 클릭 시 실행될 메소드
    @IBAction func BackBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// tableview로 표현하기 위한 extension
extension SettingViewController: UIViewControllerTransitioningDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 테이블 뷰의 셀 개수 반환 (들어갈 title의 개수)
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cell이라는 identifier를 가진 테이블 뷰 셀을 반환
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // cell의 text label의 text를 배열의 알맞는 인덱스로 지정
        cell.textLabel?.text = tableViewItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) { // 0 번째 row가 선택되었다면, 배열의 0번째는 '정보수정'
            // 정보수정 전 비밀번호 확인 화면으로 넘어가도록 설정
            guard let checkpwVC = self.storyboard?.instantiateViewController(withIdentifier: "CheckPasswordViewController") as? CheckPasswordViewController else { return }
            checkpwVC.modalPresentationStyle = .fullScreen
            checkpwVC.modalTransitionStyle = .crossDissolve
            self.present(checkpwVC, animated: true, completion: nil)
        } else if (indexPath.row == 1) { // 1 번째 row가 선택되었다면, 배열의 1번재는 '이용약관'
            // 이용 약관 화면으로 넘어가도록 설정
            guard let termVC = self.storyboard?.instantiateViewController(withIdentifier: "TermViewController") as? TermViewController else { return }
            termVC.modalPresentationStyle = .fullScreen
            termVC.modalTransitionStyle = .crossDissolve
            self.present(termVC, animated: true, completion: nil)
        } else if (indexPath.row == 2) { // 0 번째 row가 선택되었다면, 배열의 0번째는 '서비스 탈퇴'
            // 서비스 탈퇴 화면으로 넘어가도록 설정
            guard let secessionVC = self.storyboard?.instantiateViewController(withIdentifier: "SecessionViewController") as? SecessionViewController else { return }
            secessionVC.modalPresentationStyle = .fullScreen
            secessionVC.modalTransitionStyle = .crossDissolve
            self.present(secessionVC, animated: true, completion: nil)
        }
    }
    
    
}
