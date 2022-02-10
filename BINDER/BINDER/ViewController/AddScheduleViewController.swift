//
//  AddScheduleViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/23.
//

import UIKit
import Firebase

// 일정 추가 시 사용되는 뷰 컨트롤러
class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scheduleTitle: UITextField!
    @IBOutlet weak var schedulePlace: UITextField!
    @IBOutlet weak var scheduleTime: UITextField!
    @IBOutlet weak var scheduleMemo: UITextView!
    @IBOutlet weak var okBtn: UIButton!
    
    var date: String!
    var editingTitle: String!
    var isEditMode: Bool = false
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateLabel.text = date
        self.scheduleMemo.layer.borderWidth = 1.0
        self.scheduleMemo.layer.borderColor = UIColor.systemGray6.cgColor
        
        // 만약 넘어온 수정할 제목이 넘어와서 nil이 아니라면,
        if (self.editingTitle != nil) {
            // 버튼의 타이틀을 일정 수정하기로 변경
            self.okBtn.setTitle("일정 수정하기", for: .normal)
            // 내용이 있다는 의미이므로 데이터베이스에서 다시 받아와서 textfield의 값으로 설정
            self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document(self.editingTitle).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.isEditMode = true
                    let data = document.data()
                    let memo = data?["Memo"] as? String ?? ""
                    self.scheduleMemo.text = memo
                    let place = data?["Place"] as? String ?? ""
                    self.schedulePlace.text = place
                    let title = data?["Title"] as? String ?? ""
                    self.scheduleTitle.text = title
                    let time = data?["Time"] as? String ?? ""
                    self.scheduleTime.text = time
                } else {
                    print("Document does not exist")
                }
            }
            
        }
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // 취소 버튼 클릭 시 실행되는 메소드
    @IBAction func CancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 추가 버튼 클릭 시 실행되는 메소드
    @IBAction func AddScheduleSubmitBtn(_ sender: Any) {
        // 날짜 받아오기
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "YYYY-MM-dd HH:mm"
        let current_time_string = formatter_time.string(from: Date())
        
        // 수정 모드라면,
        if (isEditMode == true) {
            // 원래 데이터베이스에 저장되어 있던 일정은 삭제하고 새롭게 수정한 내용으로 추가 후 현재 modal dismiss
            self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document(editingTitle).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(date).document(scheduleTitle.text!).setData([
                "Title": scheduleTitle.text!,
                "Place": schedulePlace.text!,
                "Date" : dateLabel.text!,
                "Time": scheduleTime.text!,
                "Memo": scheduleMemo.text!,
                "SavedTime": current_time_string ])
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
        else {
            // 수정 모드가 아니라면,
            if (scheduleTitle.text != "") {
                if ((scheduleTitle.text?.trimmingCharacters(in: .whitespaces)) != "") {
                    // 데이터베이스에 입력된 내용 추가
                    self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(date).document(scheduleTitle.text!).setData([
                        "Title": scheduleTitle.text!,
                        "Place": schedulePlace.text!,
                        "Date" : dateLabel.text!,
                        "Time": scheduleTime.text!,
                        "Memo": scheduleMemo.text!,
                        "SavedTime": current_time_string ])
                    { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                    
                    // 존재하는 도큐먼트의 수만큼 Count에 숫자 더해주기
                    self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(date).getDocuments()
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
                                self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document("Count").setData(["count": count])
                                { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    }
                                }
                            } else {
                                // 현재 존재하는 데이터들이 여러 개면, Count 도큐먼트를 포함한 것이므로
                                // 하나를 뺀 수로 지정해서 저장해줌
                                self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(self.date).document("Count").setData(["count": count-1])
                                { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
