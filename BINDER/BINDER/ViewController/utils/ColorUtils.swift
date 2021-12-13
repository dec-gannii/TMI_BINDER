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
        let colors: [String] = ["A80101", "FFCB00", "13203E"]
        let randomColor = colors.randomElement()!
        return randomColor
    }
}
