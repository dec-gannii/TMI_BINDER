//
//  StudentSubInfoVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

struct StudentSubInfoVCDBFunctions {
    func DeleteUser(self : StudentSubInfoController) {
        let user = Auth.auth().currentUser // 사용자 정보 가져오기
        
        user?.delete { error in
            if let error = error {
                // An error happened.
                print("delete user error : \(error)")
            } else {
                // Account deleted.
                // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
                var docRef = db.collection("teacher").document(user!.uid)
                
                docRef.delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                
                docRef = db.collection("student").document(user!.uid)
                
                docRef.delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                
                docRef = db.collection("parent").document(user!.uid)
                
                docRef.delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
        }
    }
    
    func UpdateStudentSubInfo(age : String, phonenum : String, goal : String) {
        db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
            "age": age,
            "phonenum": phonenum,
            "goal": goal
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func UpdateTeacherSubInfo(parentPW : String) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
            "parentPW": parentPW
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func CheckStudentPhoneNumberForParent(phoneNumber: String, self: StudentSubInfoController, goal : String) {
        db.collection("teacher").whereField("email", isEqualTo: goal).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                for document in querySnapshot!.documents {
                    // 선생님 비밀번호
                    let data = document.data()
                    self.tpassword = data["parentPW"] as? String ?? ""
                    
                    if self.phonenum == "" {
                        self.phoneAlertLabel.text = "전화번호를 작성해주세요."
                        self.phoneAlertLabel.isHidden = false
                    }
                    else if ((self.phonenumTextField.text!.contains("-") && self.phonenumTextField.text!.count >= 15) || (self.phonenumTextField.text!.count >= 12 && !self.phonenumTextField.text!.contains("-"))) {
                        self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                        self.phoneAlertLabel.isHidden = false
                    }
                    else if self.tpassword != self.ageShowPicker.text! {
                        self.ageAlertLabel.text = StringUtils.tEmailNotMatch.rawValue
                        self.ageAlertLabel.isHidden = false
                    }
                    else {
                        self.goalAlertLabel.isHidden = true
                        self.phoneAlertLabel.isHidden = true
                        self.ageAlertLabel.isHidden = true
                        
                        if phoneNumber != "" {
                            db.collection("student").whereField("phonenum", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                    self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                                    self.phoneAlertLabel.isHidden = false
                                } else {
                                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                                        return
                                    }
                                    for document in querySnapshot!.documents {
                                        let data = document.data()
                                        var sphonenum = data["phonenum"] as? String ?? ""
                                        
                                        if sphonenum == phoneNumber {
                                            db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
                                                "teacherEmail": self.goal,
                                                "childPhoneNumber": phoneNumber
                                            ]) { err in
                                                if let err = err {
                                                    print("Error adding document: \(err)")
                                                }
                                            }
                                            guard let tb = self.storyboard?.instantiateViewController(withIdentifier: "ParentTabBarController") as? TabBarController else { return }
                                            tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                                            self.present(tb, animated: true, completion: nil)
                                        } else {
                                            self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                                            self.phoneAlertLabel.isHidden = false
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            self.phoneAlertLabel.text = StringUtils.phoneNumAlert.rawValue
                            self.phoneAlertLabel.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    func SaveChildPhoneNum(childPhoneNumber : String) {
        // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
        
        var childPhoneNumberWithDash = "" // '-'가 들어간 번호로 다시 만들어 주기 위해 사용
        if (childPhoneNumber.contains(" - ")) { /// '-'가 있는 휴대폰 번호의 경우
            childPhoneNumberWithDash = childPhoneNumber // '-'가 들어간 번호 변수에 그대로 사용
        } else {  /// '-'가 없는 휴대폰 번호의 경우
            var firstPart = "" // 010 파트
            var secondPart = "" // 중간 번호 파트
            var thirdPart = "" // 끝 번호 파트
            var count = 0 // 몇 개의 숫자를 셌는지 파악하기 위한 변수
            
            for char in childPhoneNumber{ // childPhoneNumber가 String이므로 하나하나의 문자를 사용
                if (count >= 0 && count <= 2) { // 0-2번째에 해당하는 수는 010 파트로 저장
                    firstPart += String(char)
                } else if (count >= 3 && count <= 6){ // 3-6번째에 해당하는 수는 중간 번호 파트로 저장
                    secondPart += String(char)
                } else if (count >= 7 && count <= 10){ // 7-10번째에 해당하는 수는 끝 번호 파트로 저장
                    thirdPart += String(char)
                }
                // 한 번 할 때마다 count 하나씩 증가
                count = count + 1
                
            }
            // '-'가 들어간 번호 변수에 010 파트와 중간 번호 하트, 끝 번호 파트를 '-'로 연결해서 저장
            childPhoneNumberWithDash = firstPart + " - " + secondPart + " - " + thirdPart
        }
        
        db.collection("parent").document(Auth.auth().currentUser!.uid).updateData([
            "childPhoneNumber": childPhoneNumberWithDash
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
}
