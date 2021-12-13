//
//  PortfolioViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import Firebase

class ProtfolioViewController: UIViewController {
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var studentListView: UIView!
    
    @IBOutlet weak var topView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.layer.shadowOffset = CGSize(width: 2, height: 3)
        topView.layer.shadowRadius = 5
        topView.layer.shadowOpacity = 0.3
        
        getUserInfo()
    }
    
    func getUserInfo() {
        studentListView.setNeedsDisplay()
    }
}
