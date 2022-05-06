//
//  PortfolioTableViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/22.
//

import UIKit
import Firebase
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
    
    let db = Firestore.firestore()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView 관련 delegate, dataSource 처리
        portfolioTableView.delegate = self
        portfolioTableView.dataSource = self
        
        // TableView 분리선 없애기
        portfolioTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        GetUserInfoInPortfolioTableViewController(self: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingHUD.hide()
        }
        self.portfolioTableView.reloadData() // tableview 다시 그려주기
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil) // 이전 화면 보이도록 하기
    }
}
extension PortfolioTableViewController: UITableViewDelegate, UITableViewDataSource {
    /// 테이블 셀 개수
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == infos.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlusPortfolioCell")! as! PlusPortfolioCell
            if (indexPath.row == 7 || self.isShowMode == true) { // 총 7개의 정보가 모두 차거나 포트폴리오 조회인 경우
                cell.isHidden = true // 정보 추가 셀 숨기기
            } else {
                cell.isHidden = false
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioDefaultCell")! as! PortfolioDefaultCell
            GetPortfolioFactors(self: self, indexPath: indexPath, cell: cell)
            
            return cell
        }
    }
    
    /// didDelectRowAt: 셀 전체 클릭
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 플러스 row
        if indexPath.row == infos.count {
            performSegue(withIdentifier: "addPortfolioItemSegue", sender: nil)
        }
    }
}
