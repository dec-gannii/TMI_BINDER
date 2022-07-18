//
//  DesignShare.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/01.
//

import Foundation
import UIKit
import FSCalendar

struct LoginDesign {
    var textColor = UIColor.black
    var bgColor = UIColor.darkGray.cgColor
}

struct ViewDesign {
    var EdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var borderWidth = 1.0
    var borderColor = UIColor.systemGray6.cgColor
    var shadowColor = UIColor.black.cgColor
    
    var titleColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100) // 토글 등 보여질 색상
    
    var viewconerRadius = CGFloat(30)
    var childViewconerRadius = CGFloat(15)
    var shadowOffset = CGSize(width: 2, height: 3)
    var shadowRadius = CGFloat(5)
    var shadowOpacity = Float(0.3)
}

struct CalendarDesign {
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 MM월"
        return df
    }()
    
    func setCalendar(calendarView: FSCalendar, monthLabel: UILabel) {
        calendarView.headerHeight = 0
        calendarView.scope = .month
        monthLabel.text = dateFormatter.string(from: calendarView.currentPage)
    }
    
    var headerHeight = CGFloat(16)
    var weekdayHeight = CGFloat(14)
    
    var calendarColor = UIColor.blue
    var calendarTodayColor = UIColor.skyBlue
    var calendartitleColor = UIColor.gray2
    var calendarSelectDateColor = UIColor.gray4

    var headerFont = UIFont.systemFont(ofSize: 12)
    var titleFont = UIFont.systemFont(ofSize: 13)
}

struct ChartDesign {
    var gridColor = UIColor.gray2
    
    var chartColor_60 = UIColor.skyBlue
    var chartColor_70 = UIColor(red: 158, green: 211, blue: 255, alpha: 1)
    var chartColor_80 = UIColor(red: 84, green: 179, blue: 255, alpha: 1)
    var chartColor_90 = UIColor(red: 0, green: 141, blue: 255, alpha: 1)
    var chartColor_100 = UIColor.blue
}

struct ButtonDesign {
    var cornerRadius = CGFloat(10)
    var cornerbtnRadius = CGFloat(5)
    var bgColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
}

struct MyCollectionViewModel {
    let title: String
}
