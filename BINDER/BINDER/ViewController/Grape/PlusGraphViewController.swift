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

class PlusGraphViewController:UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    @IBOutlet weak var studyShowPicker: UITextField!
    @IBOutlet weak var scoreTextField: UITextField!
    
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    let study = ["3월모고","1학기중간","6월모고","1학기기말","9월모고","2학기중간","11월모고","2학기기말"]
    var todayStudy = "0"
    var todayScore = "0"
    
    var userName = ""
    var userEmail = ""
    var userSubject = ""
    var userType = ""
    
//    var userType = ""
//    var studentName = ""
//    var studentEmail = ""
    
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
        getScore()
        
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
            // 데이터 저장
            docRef.document(todayStudy).setData([
                "type": todayStudy,
                "score":todayScore,
                "isScore": "true"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            docRef.getDocuments()
            {
                (querySnapshot, err) in
                
                if let err = err
                {
                    print("Error getting documents: \(err)");
                }
                else
                {
                    var count = 0
                    for document in querySnapshot!.documents {
                        count += 1
                        print("\(document.documentID) => \(document.data())");
                    }
                    
                    // 현재 존재하는 데이터가 하나면,
                    if (count == 1) {
                        // 1으로 저장
                        docRef.document("Count").setData(["count": count])
                        { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    } else {
                        // 현재 존재하는 데이터들이 여러 개면, Count 도큐먼트를 포함한 것이므로
                        // 하나를 뺀 수로 지정해서 저장해줌
                        docRef.document("Count").setData(["count": count-1])
                        { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            }
                        }
                    }
                    guard let graphVC = self.storyboard?.instantiateViewController(withIdentifier: "GraphViewController") as? GraphViewController else { return }
                    
                    graphVC.modalTransitionStyle = .crossDissolve
                    graphVC.modalPresentationStyle = .fullScreen
                    
                    graphVC.userName = self.userName
                    graphVC.userEmail = self.userEmail
                    graphVC.userSubject = self.userSubject
                    graphVC.userType = "student"
//                    graphVC.studentName = self.userName
//                    graphVC.studentEmail = self.userEmail
                    self.present(graphVC, animated: true, completion: nil)
                    //            if let preVC = self.presentingViewController as? UIViewController {
                    //                preVC.dismiss(animated: true, completion: nil)
                    //            }
                }
                }
            }
            
            
            
    }
    
    func getScore() {
        db.collection("student").document(Auth.auth().currentUser!.uid).collection("Graph").whereField("type", isEqualTo: todayStudy)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            
                            let score = document.data()["score"] as? String ?? ""
                            self.scoreTextField.text = score
                            break
                        }
                    }
                }
            }
        self.scoreTextField.text = ""
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
}
