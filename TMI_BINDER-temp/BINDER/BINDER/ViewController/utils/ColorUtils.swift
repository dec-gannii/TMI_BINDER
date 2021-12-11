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
        let colors: [String] = ["224C86", "91B15A", "A4D3DE", "C04076", "DD613C", "F0D56C"]
        let randomColor = colors.randomElement()!
        return randomColor
    }
}
