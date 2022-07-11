//
//  PortfolioTableViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/22.
//

import UIKit
import Kingfisher

// 포트폴리오 정보 뷰 컨트롤러 (tableview 활용)
public class PortfolioTableViewController: UIViewController {
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var portfolioTableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    
    var infos: [String] = []
    var teacherAttitudeArray: [Int] = []
    var teacherManagingSatisfyScoreArray: [Int] = []
    var isShowMode: Bool = false
    var showModeEmail: String = ""
    var isShowOK: Bool = false
    var content: [String] = []
    var teacherUid: String = ""
    
    var myPageDB = MyPageDBFunctions()
    var functionShare = FunctionShare()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView 관련 delegate, dataSource 처리
        portfolioTableView.delegate = self
        portfolioTableView.dataSource = self
        
        // TableView 분리선 없애기
        portfolioTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        myPageDB.GetUserInfoInPortfolioTableViewController(self: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        functionShare.LoadingShow(sec: 1)
        self.portfolioTableView.reloadData() // tableview 다시 그려주기
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil) // 이전 화면 보이도록 하기
    }
}
extension PortfolioTableViewController: UITableViewDelegate, UITableViewDataSource {
    /// 테이블 셀 개수
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioDefaultCell")! as! PortfolioDefaultCell
        myPageDB.GetPortfolioFactors(self: self, indexPath: indexPath, cell: cell)
        
        return cell
    }
}
