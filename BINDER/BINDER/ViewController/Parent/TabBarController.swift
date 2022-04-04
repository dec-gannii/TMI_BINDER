//
//  TabBarController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit

// TabBar를 사용하기 위해 만들어진 Controller
class TabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            let tabBarIndex = tabBarController.selectedIndex
            if tabBarIndex == 0 {
                //do your stuff
                LoadingHUD.isLoaded = false
            }
       }
}
