//
//  GrapeViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/05.
//

import UIKit
import Charts
import BLTNBoard
import FirebaseFirestore

class GraphViewController: UIViewController {

    //@IBOutlet var plusButton: UIButton!
    @IBOutlet var barChartView: BarChartView!

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var todoTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var days: [String]!
    var scores: [Double]!
    let floatValue: [CGFloat] = [4,4]
    var barColors = [UIColor]()
    
    var todos = Array<String>()
    
   /* private lazy var boardManager: BLTNItemManager = {
        
        let item = BLTNPageItem(title: "Push")
        item.actionButtonTitle = "추가하기"
        item.alternativeButtonTitle = "취소하기"
        item.descriptionText = "성적 타입과 성적을 입력하세요"
        
        item.actionHandler = { _ in
            GrapeViewController.didTapBoardContinue()
        }
        item.alternativeHandler = { _ in
            GrapeViewController.didTapBoardSkip()
        }
        item.appearance.actionButtonColor = .systemGreen
        item.appearance.alternativeButtonTitleColor = .gray
        
       return BLTNItemManager(rootItem: item)
    }()
    
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //plusButton.backgroundColor = .link
        //plusButton.setTitleColor(.white, for: .normal)
        
        days = ["3월모고","1학기중간","6월모고","1학기기말"]
        scores = [68.0,88.5,70.5,90.0]
        
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        
        allRound()
        barColorSetting()
        setChart(dataPoints: days, values: scores)
    }
    
    func allRound() {
        okButton.clipsToBounds = true
        okButton.layer.cornerRadius = 20
        
        plusButton.clipsToBounds = true
        plusButton.layer.cornerRadius = 20
    }
    
    func barColorSetting(){
        barColors.append(UIColor.init(displayP3Red: 22/255, green: 32/255, blue: 60/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 82/255, green: 90/255, blue: 109/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 126/255, green: 129/255, blue: 144/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 146/255, green: 150/255, blue: 160/255, alpha: 1))
        barColors.append(UIColor.init(displayP3Red: 175/255, green: 178/255, blue: 186/255, alpha: 1))
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "성적 그래프")
        
        // 차트 컬러
        chartDataSet.colors = barColors
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.drawValueAboveBarEnabled = true
        
        // 선택 안되게
        chartDataSet.highlightEnabled = false
        // 줌 안되게
        barChartView.doubleTapToZoomEnabled = false
        
        // 차트 점선으로 표시
        barChartView.xAxis.gridColor = .clear
        barChartView.leftAxis.gridColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.4)
        barChartView.leftAxis.gridLineWidth = CGFloat(1.0)
        barChartView.leftAxis.gridLineDashLengths = floatValue
        
        // X축 레이블 위치 조정
        barChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        barChartView.legend.setCustom(entries: [])
        
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        barChartView.xAxis.setLabelCount(dataPoints.count, force: false)
        
        // 오른쪽 레이블 제거
        barChartView.rightAxis.enabled = false
        
        // 기본 애니메이션
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        // 옵션 애니메이션
        //barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)

    
    }
    /*
    @IBAction func didTapButton(){
        boardManager.showBulletin(above: self)
    }
    
    static func didTapBoardContinue(){
        print("Did tap continue")
    }
    
    static func didTapBoardSkip(){
        print("Did tap skip")
    }
     */
    @IBAction func goHome(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func goButtonClicked(_ sender: Any) {
        todos.append(todoTF.text ?? "")
        tableView.reloadData()
    }
}

extension GraphViewController:UITableViewDataSource {
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todos.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as! Todocell
    let todo = self.todos[indexPath.row]
    
    cell.TodoLabel.text = "\(todo)"
    
    return cell
}
}
