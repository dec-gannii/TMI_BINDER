//
//  LoadingHUD.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/31.
//

import UIKit

class LoadingHUD: NSObject {
    private static let sharedInstance = LoadingHUD()
    private var popupView: UIImageView?
    static var isLoaded = false
    
    class func show() {
        let popupView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
//        print("width: \(UIScreen.main.bounds.size.width), height: \(UIScreen.main.bounds.size.height)")
        popupView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
//        popupView.backgroundColor = .none
        popupView.animationImages = LoadingHUD.getAnimationImageArray()    // 애니메이션 이미지
        popupView.animationDuration = 4.0
        popupView.animationRepeatCount = 0    // 0일 경우 무한반복

        // popupView를 UIApplication의 window에 추가하고, popupView의 center를 window의 center와 동일하게 합니다.
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(popupView)
            popupView.center = window.center
            popupView.startAnimating()
            sharedInstance.popupView?.removeFromSuperview()
            sharedInstance.popupView = popupView
        }
    }

    private class func getAnimationImageArray() -> [UIImage] {
        var animationArray: [UIImage] = []
        for index in 1...166 {
            var i = ""
            if (index < 10) {
                i = "0000\(index)"
            } else if (10 <= index && index < 100) {
                i = "000\(index)"
            } else {
                i = "00\(index)"
            }
            animationArray.append(UIImage(named: "\(i)")!)
        }

        return animationArray
    }
    
    class func hide() {
            if let popupView = sharedInstance.popupView {
                popupView.stopAnimating()
                popupView.removeFromSuperview()
            }
        }
}
