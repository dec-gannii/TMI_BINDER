//
//  FunctoinShare.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/01.
//

import Foundation
import UIKit
import FSCalendar
import FirebaseStorage

struct FunctionShare{
    func viewDecorating(btn: UIButton, view: UIView, design: ViewDesign){
        btn.layer.cornerRadius = design.viewconerRadius
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
    
    /// UI setting
    func setBorder(textList: Array<UITextView>, design: ViewDesign) {
        for textView in textList {
            textView.layer.borderWidth = design.borderWidth
            textView.layer.borderColor = design.borderColor
        }
    }
    
    func allRound(array: Array<UIView>, design: ButtonDesign) {
        for view in array {
            view.layer.cornerRadius = design.cornerRadius
        }
    }
    
    /// calendar custom
    func calendarColor(view: FSCalendar, design: CalendarDesign) {
        
        view.appearance.weekdayTextColor = .systemGray
        view.appearance.titleWeekendColor = .black
        view.appearance.headerTitleColor =  design.calendarColor
        view.appearance.eventDefaultColor = design.calendarColor
        view.appearance.eventSelectionColor = design.calendarColor
        view.appearance.titleSelectionColor = design.calendarColor
        view.appearance.borderSelectionColor = design.calendarColor
        view.appearance.todayColor = design.calendarTodayColor
        view.appearance.titleTodayColor = .black
        view.appearance.todaySelectionColor = .white
        view.appearance.selectionColor = .none
    }
    
    // 캘린더 텍스트 스타일 설정을 위한 메소드
    func calendarText(view: FSCalendar, design: CalendarDesign) {
        view.headerHeight = CGFloat(design.headerHeight)
        view.appearance.headerTitleFont = design.headerFont
        view.appearance.headerMinimumDissolvedAlpha = 0.0
        view.appearance.headerDateFormat = "YYYY년 M월"
        view.appearance.titleFont = design.titleFont
        view.appearance.weekdayFont = design.headerFont
        view.locale = Locale(identifier: "ko_KR")
        view.weekdayHeight = CGFloat(design.weekdayHeight)
    }
    
    func placeholderSetting(_ textView: UITextView) {
        textView.delegate = textView as! UITextViewDelegate // 유저가 선언한 outlet
        textView.text = StringUtils.contentNotExist.rawValue
        textView.textColor = UIColor.lightGray
    }
    
    func ViewBorderRound(_ view: UIView) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
    }
}

