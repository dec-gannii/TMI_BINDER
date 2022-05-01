//
//  DesignShare.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/01.
//

import Foundation
import UIKit

struct LoginDesign {
    var textColor = UIColor.black
    var bgColor = UIColor.darkGray.cgColor
}

struct ViewDesign {
    var EdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var borderWidth = 1.0 // 뷰들간
    var borderColor = UIColor.systemGray6.cgColor
    var shadowColor = UIColor.black.cgColor
    
    var titleColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100) // 토글등 보여질 색상
    
    var viewconerRadius = CGFloat(30)
    var childViewconerRadius = CGFloat(15)
    var shadowOffset = CGSize(width: 2, height: 3)
    var shadowRadius = CGFloat(5)
    var shadowOpacity = Float(0.3)
}

struct CalendarDesign {
    
    var headerHeight = CGFloat(16)
    var weekdayHeight = CGFloat(14)
    
    var calendarColor = UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
    var calendarTodayColor = UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 0.3)

    var headerFont = UIFont.systemFont(ofSize: 12)
    var titleFont = UIFont.systemFont(ofSize: 13)
}

struct ChartDesign {
    
    var gridColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.4)
    
    var chartColor_60 = UIColor(displayP3Red: 22/255, green: 32/255, blue: 60/255, alpha: 1)
    var chartColor_70 = UIColor(displayP3Red: 82/255, green: 90/255, blue: 109/255, alpha: 1)
    var chartColor_80 = UIColor(displayP3Red: 126/255, green: 129/255, blue: 144/255, alpha: 1)
    var chartColor_90 = UIColor(displayP3Red: 146/255, green: 150/255, blue: 160/255, alpha: 1)
    var chartColor_100 = UIColor(displayP3Red: 175/255, green: 178/255, blue: 186/255, alpha: 1)
}

struct ButtonDesign {
    var cornerRadius = CGFloat(10)
    var bgColor = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
}
