//
//  GraphViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/16.
//

import UIKit
import Firebase
import Charts
import BLTNBoard

public class GraphViewController: UIViewController {
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var userIndex: Int!
    var days: [String]!
    var scores: [Double]!
    var floatValue: [CGFloat]!
    var barColors = [UIColor]()
    
    var chartDesign = ChartDesign()
    
    func _init(){
        userEmail = ""
        userSubject = ""
        userName = ""
        userType = ""
        userIndex = 0
        days = []
        scores = []
        floatValue = [5,5]
        barColors = barColorSetting(design: chartDesign)
    }
    
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet weak var plusButton: UIButton!
    
    public override func viewWillAppear(_ animated: Bool) {
//        GetUserAndClassInfo(self: self)
        getScores()
        super.viewWillAppear(true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        getScores()
//        GetUserInfoInDetailClassVC(self: self)
        
        // 데이터 없을 때 나올 텍스트 설정
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
    }
    
    @IBAction func PlusScores(_ sender: Any) {
        guard let plusGraphVC = self.storyboard?.instantiateViewController(withIdentifier: "PlusGraphViewController") as? PlusGraphViewController else { return }
        
        plusGraphVC.modalTransitionStyle = .crossDissolve
        plusGraphVC.modalPresentationStyle = .fullScreen
        
        // 값 보내주는 역할
        plusGraphVC.userName = self.userName
        plusGraphVC.userEmail = self.userEmail
        plusGraphVC.userSubject = self.userSubject
        
        self.present(plusGraphVC, animated: true, completion: nil)
    }
    
    func getScores() {
        var studentUid = "" // 학생의 uid 변수
        // 빈 배열 형성
        days = []
        scores = []
        
        // 받은 이메일이 nil이 아니라면
        if let email = self.userEmail {
            var studentEmail = ""
            if (self.userType == "student") { // 현재 로그인한 사용자가 학생이라면 현재 사용자의 이메일 받아오기
                studentEmail = (Auth.auth().currentUser?.email)!
            } else { // 아니라면 전 view controller에서 받아온 이메일로 설정
                studentEmail = email
            }
            
            //            GetScores(self: self, studentEmail: studentEmail)
        }
    }
}
