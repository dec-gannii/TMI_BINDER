//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit

extension UIColor {
    
    convenience init(rgb: Int, alpha: CGFloat? = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha ?? 1.0
        )
    }
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    @nonobjc class var white: UIColor {
      return UIColor(white: 1.0, alpha: 1.0)
    }

    @nonobjc class var gray2: UIColor {
      return UIColor(white: 194.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var gray1: UIColor {
      return UIColor(white: 245.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var black: UIColor {
      return UIColor(white: 0.0, alpha: 1.0)
    }

    @nonobjc class var blue: UIColor {
      return UIColor(red: 1.0 / 255.0, green: 104.0 / 255.0, blue: 1.0, alpha: 1.0)
    }

    @nonobjc class var gray3: UIColor {
      return UIColor(red: 179.0 / 255.0, green: 178.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var gray17: UIColor {
      return UIColor(white: 215.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var gray15: UIColor {
      return UIColor(white: 229.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var gray4: UIColor {
      return UIColor(red: 84.0 / 255.0, green: 83.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var skyBlue: UIColor {
      return UIColor(red: 205.0 / 255.0, green: 231.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
}
