//
//  PlusgraphViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/04.
//

import UIKit
import FirebaseFirestore

class PlusgraphViewController:UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var studyShowPicker: UITextField!
    @IBOutlet weak var scoreTextField: UITextField!
    
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    let study = ["3월모고","1학기중간","6월모고","1학기기말","9월모고","2학기중간","11월모고","2학기기말"]
    var todayStudy = "0"
    var todayScore = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studyLabel.text = nil
        scoreLabel.text = nil
        
        createPickerView()
        dismissPickerView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }


    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return study.count
    }


    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        todayStudy = study[row]
        return study[row]
        }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        studyShowPicker.text = study[row]
        }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        studyShowPicker.tintColor = .clear
        
        studyShowPicker.inputView = pickerView
      }

      func dismissPickerView() {
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
        studyShowPicker.text = "\(todayStudy)"
        self.studyShowPicker.resignFirstResponder()
        
    }
    
    @objc func cancelPicker() {
        studyShowPicker.resignFirstResponder()
    }

    
    @IBAction func goPlus(_ sender: Any) {
        todayScore = scoreTextField.text!
        if todayStudy == "0"{
            studyLabel.text = "하나를 선택해주세요"
            
        } else if todayScore == "" {
            scoreLabel.text = "성적을 작성해주세요"
            
        } else {
            // 데이터 저장
            var ref: DocumentReference? = nil
            ref = db.collection("Grape").addDocument(data: [
                "Type": todayStudy,
                "Score": todayScore
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            if let preVC = self.presentingViewController as? UIViewController {
                preVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
