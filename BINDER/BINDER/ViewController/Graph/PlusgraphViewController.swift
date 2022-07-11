//
//  PlusGrapeViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/05.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

public class PlusGraphViewController:UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var ref: DatabaseReference!
    
    @IBOutlet weak var studyShowPicker: UITextField!
    @IBOutlet weak var scoreTextField: UITextField!
    
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var functionShare = FunctionShare()
    var detailClassDB = DetailClassDBFunctions()
    
    var todayStudy: String!
    var todayScore: String!
    var userName: String!
    var userEmail: String!
    var userSubject: String!
    var userType: String!
    let study = ["3월 모평","1차 중간","6월 모평","1차 기말","9월 모평","2차 중간","11월 모평","2차 기말"]
    
     public override func viewDidLoad() {
        super.viewDidLoad()
         
         scoreTextField.keyboardType = .numberPad
         
         var textfields = [UITextField]()
         textfields = [self.studyShowPicker, self.scoreTextField]
         
         functionShare.textFieldPaddingSetting(textfields)
         
         studyLabel.text = nil
         scoreLabel.text = nil
         
         createPickerView()
         dismissPickerView()
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return study.count
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return study[row]
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.todayStudy = study[row]
        studyShowPicker.text = study[row]
    }
    
    public func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        studyShowPicker.tintColor = .clear
        studyShowPicker.inputView = pickerView
    }
    
    public func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBT = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(donePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelBT = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelBT,flexibleSpace,doneBT], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        studyShowPicker.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        studyShowPicker.text = todayStudy
        self.studyShowPicker.resignFirstResponder()
        detailClassDB.GetScoreForEdit(self: self, todayStudy: todayStudy)
    }
    
    @objc func cancelPicker() {
        studyShowPicker.resignFirstResponder()
    }
    
    
    @IBAction func goPlus(_ sender: Any) {
        todayScore = scoreTextField.text!
        let docRef = db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph")
        if todayStudy == "0"{
            studyLabel.text = "하나를 선택해주세요"
        } else if todayScore == "" {
            scoreLabel.text = "성적을 작성해주세요"
        } else {
            detailClassDB.SaveGraphScore(todayStudy: todayStudy, todayScore: todayScore, self: self)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
