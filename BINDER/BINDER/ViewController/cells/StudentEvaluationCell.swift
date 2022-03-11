//
//  StudentEvaluationCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit

class StudentEvaluationCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let months = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    
    @IBOutlet weak var classColorView: UIView!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var monthPickerView: UITextField!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    @IBOutlet weak var showMoreInfoButton: UIButton!
    
    var selectedMonth = ""
    
    @IBAction func ShowMoreInfoBtnClicked(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.clipsToBounds = true
        cellBackgroundView.layer.cornerRadius = 15
        
        createPickerView()
        dismissPickerView()
        
        classColorView.makeCircle()
        
        monthPickerView.backgroundColor = .white
        monthPickerView.borderStyle = .none
        monthPickerView.textAlignment = .right
        monthPickerView.clipsToBounds = true
        monthPickerView.layer.cornerRadius = 10
        monthPickerView.rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 5.0, height: 0.0))
        monthPickerView.rightViewMode = .always
        
        self.selectionStyle = .none
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.selectedMonth = months[row]
        return months[row]
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        var label = UILabel()
//        if let v = view as? UILabel { label = v }
//        label.font = UIFont (name: "Helvetica Neue")
//        label.text =  months[row]
//        label.textAlignment = .center
//        return label
//    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        monthPickerView.tintColor = .clear
        
        monthPickerView.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBT = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(donePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelBT = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelBT,flexibleSpace,doneBT], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        monthPickerView.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        monthPickerView.text = "\(self.selectedMonth)"
        self.monthPickerView.resignFirstResponder()
        
    }
    
    @objc func cancelPicker() {
        monthPickerView.resignFirstResponder()
    }
}
