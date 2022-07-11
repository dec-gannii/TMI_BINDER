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
import FirebaseAuth

public class GraphViewController: UIViewController {
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var userIndex: Int!
    var studentEmail: String!
    var studentName: String!
    var days: [String]!
    var scores: [Double]!
    var floatValue: [CGFloat]!
    var barColors = [UIColor]()
    
    var chartDesign = ChartDesign()
    var detailClassDB = DetailClassDBFunctions()
    
    func _init(){
        userEmail = ""
        userSubject = ""
        userName = ""
        userType = ""
        userIndex = 0
        days = []
        scores = []
        floatValue = [5,5]
        studentEmail = ""
        studentName = "" 
    }
    
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet weak var plusButton: UIButton!
    
    public override func viewWillAppear(_ animated: Bool) {
        days = []
        scores = []
        guard let myClassDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassDetailViewController") as? MyClassDetailViewController else { return }
        getScores()
        super.viewWillAppear(true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        days = []
        scores = []
        
        // 데이터 없을 때 나올 텍스트 설정
        barChartView.noDataText = "입력된 성적이 없어요! 입력해보는 건 어떨까요?"
        barChartView.noDataFont = .systemFont(ofSize: 14.0, weight: .bold)
        barChartView.noDataTextColor = .lightGray
        
        if self.userType == "teacher" {
            self.plusButton.isHidden = true
        } else {
            self.plusButton.isHidden = false
        }
        
        getScores()
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
        // 빈 배열 형성
        days = []
        scores = []
        
        var studentEmail = ""
        if let email = self.userEmail {
            if self.userType == "student" {
                studentEmail = (Auth.auth().currentUser?.email)!
            } else {
                studentEmail = email
            }
            detailClassDB.GetScores(self: self, studentEmail: studentEmail)
        }
    }
}
