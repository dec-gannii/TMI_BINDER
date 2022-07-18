//
//  barChartFunction.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/06.
//

import UIKit
import Charts

/// bar chart UI setting
func barColorSetting(design:ChartDesign) -> [UIColor]{
    var barColors = [UIColor]()
    
    barColors.append(design.chartColor_60)
    barColors.append(design.chartColor_70)
    barColors.append(design.chartColor_80)
    barColors.append(design.chartColor_90)
    barColors.append(design.chartColor_100)
    
    return barColors
}

func NoDataSetting(view: BarChartView) {
    // 데이터 없을 때 나올 텍스트 설정
    view.noDataText = "입력된 성적이 없어요! 입력해보는 건 어떨까요?"
    view.noDataFont = .systemFont(ofSize: 14.0, weight: .bold)
    view.noDataTextColor = .gray4
}

func setChart(dataPoints: [String], values: [Double], view:BarChartView, design:ChartDesign, colors: [UIColor],fvalue:[CGFloat]) {
    // 데이터 생성
    var dataEntries: [BarChartDataEntry] = []
    for i in 0..<dataPoints.count {
        let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
        dataEntries.append(dataEntry)
    }
    
    if (dataEntries.count < 4) {
        for i in dataPoints.count...3 {
            dataEntries.append(BarChartDataEntry(x: Double(i), y: 0))
        }
    }
    let chartDataSet = BarChartDataSet(entries: dataEntries, label: "성적 그래프")
    
    // 차트 컬러
    let chartDesign = ChartDesign()
    chartDataSet.colors = barColorSetting(design: chartDesign)
    
    // 데이터 삽입
    let chartData = BarChartData(dataSet: chartDataSet)
    view.data = chartData
    view.drawValueAboveBarEnabled = true
    chartData.barWidth = Double(0.4)
    
    // 선택 안되게
    chartDataSet.highlightEnabled = false
    
    // 줌 안되게
    view.doubleTapToZoomEnabled = false
    
    // 차트 점선으로 표시
    view.xAxis.gridColor = .clear
    view.leftAxis.gridColor = design.gridColor
    view.leftAxis.gridLineWidth = CGFloat(1.0)
    view.leftAxis.gridLineDashLengths = fvalue
    view.leftAxis.axisMaximum = 100
    view.leftAxis.axisMinimum = 0
    
    // X축 레이블 위치 조정
    view.xAxis.labelPosition = .bottom
    // X축 레이블 포맷 지정
    view.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
    view.legend.setCustom(entries: [])
    
    // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
    view.xAxis.setLabelCount(dataPoints.count, force: false)
    
    // 오른쪽 레이블 제거
    view.rightAxis.enabled = false
    
    // 기본 애니메이션
    view.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
}
