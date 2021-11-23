//
//  AddScheduleViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/23.
//

import UIKit

class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    var date: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateLabel.text = date
    }
    
    @IBAction func AddScheduleSubmitBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
