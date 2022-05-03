//
//  StudentEvaluationCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

public class StudentEvaluationCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let months = ["01월", "02월", "03월", "04월", "05월", "06월", "07월", "08월", "09월", "10월", "11월", "12월"]
    let nowDate = Date()
    
    @IBOutlet weak var classColorView: UIView!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var monthPickerView: UITextField!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    @IBOutlet weak var showMoreInfoButton: UIButton!
    
    var selectedMonth = ""
    var evaluation = ""
    var studentUid = ""
    var teacherName = ""
    var teacherEmail = ""
    var subject = ""
    
    func setStudentUID(_ studentUid: String) {
        self.studentUid = studentUid
    }
    
    func setTeacherInfo(_ teacherName: String, _ teacherEmail: String, _ subject: String) {
        self.teacherName = teacherName
        self.teacherEmail = teacherEmail
        self.subject = subject
        GetEvaluationForStudentCell(self: self)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        LoadingHUD.isLoaded = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        self.selectedMonth = dateFormatter.string(from: self.nowDate) + "월"
        self.monthPickerView.text = self.selectedMonth
        
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
        monthlyEvaluationTextView.textContainer.maximumNumberOfLines = 3
        monthlyEvaluationTextView.isScrollEnabled = false
        monthlyEvaluationTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        self.selectionStyle = .none
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return months.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return months[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedMonth = months[row]
    }
    
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
    
    func setTextView(_ Evaluation: String) {
        self.monthlyEvaluationTextView.text = Evaluation
    }
    
    @objc func donePicker() {
        GetEvaluationForStudentCell(self: self)
    }
    
    @objc func cancelPicker() {
        monthPickerView.resignFirstResponder()
    }
}
