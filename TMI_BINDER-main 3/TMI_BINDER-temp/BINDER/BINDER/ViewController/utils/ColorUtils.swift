//
//  ColorUtils.swift
//  BINDER
//
//  Created by 하유림 on 2021/12/11.
//

import Foundation

class ColorUtils {
    // circle color 랜덤 지정
    static func randomColor() -> String
    {
        let colors: [String] = ["EE7F32", "F2A444", "F6C857", "F8D772", "FFFFFF"]
        let randomColor = colors.randomElement()!
        return randomColor
    }
}
