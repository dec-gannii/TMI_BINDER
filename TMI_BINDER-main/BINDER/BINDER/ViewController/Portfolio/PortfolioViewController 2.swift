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
    
    @IBOutlet weak var contentView1: UIView!
    @IBOutlet weak var contentView2: UIView!
    @IBOutlet weak var contentView3: UIView!
    @IBOutlet weak var contentView4: UIView!
    @IBOutlet weak var contentView5: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRound()
        
        getUserInfo()
    }
    func viewRound(){
        contentView1.clipsToBounds = true
        contentView1.layer.cornerRadius = 10
        
        contentView2.clipsToBounds = true
        contentView2.layer.cornerRadius = 10
        
        contentView3.clipsToBounds = true
        contentView3.layer.cornerRadius = 10
        
        contentView4.clipsToBounds = true
        contentView4.layer.cornerRadius = 10
        
        contentView5.clipsToBounds = true
        contentView5.layer.cornerRadius = 10
       
    }
    
    func getUserInfo() {
        studentListView.setNeedsDisplay()
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
