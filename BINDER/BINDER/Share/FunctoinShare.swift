//
//  FunctoinShare.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/01.
//

import Foundation
import UIKit

func viewDecorating(btn: UIButton, view: UIView, design: ViewDesign){
    btn.layer.cornerRadius = design.viewconerRadius
    view.layer.cornerRadius = design.viewconerRadius
    view.layer.shadowColor = design.shadowColor
    view.layer.masksToBounds = false
    view.layer.shadowOffset = design.shadowOffset
    view.layer.shadowRadius = design.shadowRadius
    view.layer.shadowOpacity = design.shadowOpacity
}
