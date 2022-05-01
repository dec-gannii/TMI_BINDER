//
//  FunctoinShare.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/01.
//

import Foundation
import UIKit
import FirebaseStorage

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

func placeholderSetting(_ textView: UITextView) {
    textView.delegate = textView as! UITextViewDelegate // 유저가 선언한 outlet
    textView.text = StringUtils.contentNotExist.rawValue
    textView.textColor = UIColor.lightGray
}


