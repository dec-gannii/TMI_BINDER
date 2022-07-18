//
//  FunctoinShare.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/01.
//

import Foundation
import UIKit
import FirebaseStorage
import FSCalendar

// 캘린더 외관을 꾸미기 위한 메소드
func calendarColor(view:FSCalendar, design:CalendarDesign) {
    view.appearance.weekdayTextColor = .systemGray
    view.appearance.headerTitleColor =  design.calendartitleColor
    view.appearance.eventDefaultColor = design.calendarColor
    view.appearance.eventSelectionColor = design.calendarColor
    view.appearance.titleSelectionColor = .black
    view.appearance.borderSelectionColor = design.calendarTodayColor
    view.appearance.titleTodayColor = design.calendarColor
    view.appearance.titleDefaultColor = .black
    view.appearance.titleWeekendColor = .black
    view.appearance.todaySelectionColor = design.calendarTodayColor
    view.appearance.selectionColor = .none
    view.appearance.todayColor = design.calendarTodayColor
}

// 캘린더 텍스트 스타일 설정을 위한 메소드
func calendarText(view:FSCalendar, design:CalendarDesign) {
    view.headerHeight = CGFloat(design.headerHeight)
    view.appearance.headerTitleFont = design.headerFont
    view.appearance.headerMinimumDissolvedAlpha = 0.0
    view.appearance.headerDateFormat = "YYYY년 M월"
    view.appearance.titleFont = design.titleFont
    view.appearance.weekdayFont = design.headerFont
    view.locale = Locale(identifier: "ko_KR")
    view.weekdayHeight = CGFloat(design.weekdayHeight)
}

// 캘린더 텍스트 스타일 설정을 위한 메소드
func CalendarText_week(view:FSCalendar, design:CalendarDesign) {
    view.headerHeight = CGFloat(design.headerHeight)
    view.appearance.headerMinimumDissolvedAlpha = 0.0
    view.appearance.headerDateFormat = "YYYY년 M월"
    view.locale = Locale(identifier: "ko_KR")
    view.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    view.appearance.titleFont = UIFont.systemFont(ofSize: 14)
    view.appearance.weekdayFont = UIFont.systemFont(ofSize: 14)
    view.weekdayHeight = CGFloat(40)
}

/// UI setting
func setBorder(views:Array<UITextView>, design:ViewDesign) {
    for view in views{
        view.layer.borderWidth = design.borderWidth
        view.layer.borderColor = design.borderColor
    }
}

func allRound(views: Array<AnyObject>, design:ButtonDesign) {
    for view in views{
        view.layer.cornerRadius = design.cornerRadius
    }
}

//달별 달력 날짜 셋팅
func setUpDays(_ date: Date) -> Array<Date> {
    var days : Array<Date> = []
    let nowDate = date // 오늘 날짜
    let formatter = DateFormatter()
    
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(abbreviation: "KST")
    
    formatter.dateFormat = "M"
    let currentDate = formatter.string(from: nowDate)
    
    formatter.dateFormat = "yyyy"
    let currentYear = formatter.string(from: nowDate)
    
    formatter.dateFormat = "MM"
    let currentMonth = formatter.string(from: nowDate)
    
    var day: Int = 0
    
    switch currentDate {
    case "1", "3", "5", "7", "8", "10", "12":
        day = 31
        break
    case "2":
        if (Int(currentYear)! % 400 == 0 || (Int(currentYear)! % 100 != 0 && Int(currentYear)! % 4 == 0)) {
            day = 29
            break
        } else {
            day = 28
            break
        }
    default:
        day = 30
        break
    }
    
    for index in 1...day {
        var dayText = ""
        
        if (index < 10) {
            dayText = "0\(index)"
        } else {
            dayText = "\(index)"
        }
        
        let dayOfMonth = "\(currentYear)-\(currentMonth)-\(dayText)"
        
        formatter.dateFormat = "yyyy-MM-dd"
        let searchDate = formatter.date(from: dayOfMonth)
        days.append(searchDate!)
        
    }
    return days
}

func viewDecorating(view: UIView, design: ViewDesign){
    view.layer.cornerRadius = design.viewconerRadius
    view.layer.shadowColor = design.shadowColor
    view.layer.masksToBounds = false
    view.layer.shadowOffset = design.shadowOffset
    view.layer.shadowRadius = design.shadowRadius
    view.layer.shadowOpacity = design.shadowOpacity
}

func setTextViewUI(textList: Array<UITextView>, viewdesign: ViewDesign,btndesign: ButtonDesign) {
    // Border setting
    for textView in textList {
        textView.layer.borderWidth = viewdesign.borderWidth
        textView.layer.borderColor = viewdesign.borderColor
        
        // textview의 안쪽에 padding을 주기 위해 EdgeInsets 설정
        textView.textContainerInset = viewdesign.EdgeInsets
        // cornerRadius 지정
        textView.clipsToBounds = true
        textView.layer.cornerRadius = btndesign.cornerRadius
    }
}

func placeholderSetting(_ textView: UITextView) {
    textView.delegate = textView as! UITextViewDelegate // 유저가 선언한 outlet
    textView.text = StringUtils.contentNotExist.rawValue
    textView.textColor = UIColor.lightGray
}


