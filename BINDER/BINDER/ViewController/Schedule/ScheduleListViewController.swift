//
//  ScheduleListViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/12/04.
//

import UIKit

// 일정 리스트 뷰 컨트롤러
public class ScheduleListViewController: UIViewController {
    
    @IBOutlet weak var scheduleListViewNavigationBar: UINavigationBar!
    @IBOutlet weak var scheduleListTableView: UITableView!
    var date: String = ""
    var scheduleTitles: [String] = []
    var scheduleMemos: [String] = []
    var count: Int = 0
    var selectedTitle: String = ""
    var type: String = ""
    
    var scheduleDB = ScheduleVCDBFunctions()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        scheduleListTableView.delegate = self
        scheduleListTableView.dataSource = self
        
        self.scheduleListTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scheduleListTableView.reloadData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.scheduleTitles.removeAll()
        self.scheduleMemos.removeAll()
        
        let formatter = DateFormatter()
        
        let dateWithoutDays = self.date.components(separatedBy: " ")
        formatter.dateFormat = "YYYY-MM-dd"
        let date = formatter.date(from: dateWithoutDays[0])!
        let datestr = formatter.string(from: date)
        
        // 데이터베이스에서 일정 리스트 가져오기
        scheduleDB.ShowScheduleList(type: self.type, date: self.date, datestr: datestr, scheduleTitles: scheduleTitles, scheduleMemos: scheduleMemos, count: self.count)
        scheduleListTableView.reloadData()
    }
    
    // 일정 추가 버튼 (+) 클릭 시 사용되는 메소드
    @IBAction func AddButtonClicked(_ sender: Any) {
        guard let addScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        addScheduleVC.date = self.date // 날짜 정보를 넘겨주기
        addScheduleVC.type = self.type
        addScheduleVC.modalPresentationStyle = .fullScreen
        self.present(addScheduleVC, animated: true, completion: nil)
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil) 
    }
}

extension ScheduleListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleCell = scheduleListTableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCellTableViewCell
        
        let formatter = DateFormatter()
        
        let dateWithoutDays = self.date.components(separatedBy: " ")
        formatter.dateFormat = "YYYY-MM-dd"
        let date = formatter.date(from: dateWithoutDays[0])!
        let datestr = formatter.string(from: date)
        
        // 일정 리스트 받아와서 날짜에 맞는 일정 텍스트 설정
        scheduleDB.SetScheduleTexts(type: self.type, date: self.date, datestr: datestr, scheduleTitles: self.scheduleTitles, scheduleMemos: self.scheduleMemos, count: self.count, scheduleCell: scheduleCell, indexPathRow: indexPath.row)
        // 날짜는 선택된 날짜로 고정되도록 설정
        scheduleCell.scheduleDate.text = self.date
        
        return scheduleCell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return varCount // 셀의 개수 반환
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀이 선택되면 수정될 수 있도록 설정
        guard let editScheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddScheduleViewController else { return }
        editScheduleVC.date = self.date // 선택된 날짜 데이터 전달
        editScheduleVC.type = self.type
        editScheduleVC.editingTitle = publicTitles[indexPath.row] // 선택된 셀의 일정 제목 데이터 전달
        editScheduleVC.modalPresentationStyle = .fullScreen
        self.present(editScheduleVC, animated: true, completion: nil)
    }
    
    // 일정 삭제를 위한 메소드 - 1
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { return .delete }
    
    // 일정 삭제를 위한 메소드 - 2
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedTitle = publicTitles[indexPath.row]
        if editingStyle == .delete {
            scheduleDB.DeleteSchedule(type: self.type, date: self.date, indexPathRow: indexPath.row, scheduleListTableView: self.scheduleListTableView)
        }
    }
}
