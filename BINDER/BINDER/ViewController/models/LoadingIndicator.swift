//
//  LoadingIndicator.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/31.
//
import UIKit

class LoadingIndicator {
    static var isLoaded: Bool = false
    
    static func showLoading() {
        DispatchQueue.main.async {
            // 최상단에 있는 window 객체 획득
            guard let window = UIApplication.shared.windows.last else { return }

            let loadingIndicatorView: UIActivityIndicatorView
            if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                /// 다른 UI가 눌리지 않도록 indicatorView의 크기를 full로 할당
                loadingIndicatorView.frame = window.frame
//                loadingIndicatorView.color = UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 1.0)
                loadingIndicatorView.color = .white
                loadingIndicatorView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
                window.addSubview(loadingIndicatorView)
            }
            self.isLoaded = true

            loadingIndicatorView.startAnimating()
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
