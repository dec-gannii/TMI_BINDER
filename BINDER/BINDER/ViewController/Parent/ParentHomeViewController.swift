//
//  ParentHomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit

class ParentHomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var classColorView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var monthPickerView: UIPickerView!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    
    @IBAction func ShowMoreInfoBtnClicked(_ sender: Any) {
    }
    
}
