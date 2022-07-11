//
//  SettingVCFunctionShare_DB.swift
//  BINDER
//
//  Created by 김가은 on 2022/07/12.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

struct SettingDBFunctions {
    func Secession(self : SecessionViewController) {
        let user = Auth.auth().currentUser // 사용자 정보 가져오기
        
        user?.delete { error in
            if let error = error {
                // An error happened.
                print("delete user error : \(error)")
            } else {
                // Account deleted.
                // 선생님 학생 학부모이냐에 관계 없이 DB에 저장된 정보 삭제
                db.collection("teacher").document(user!.uid).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                db.collection("student").document(user!.uid).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                
                db.collection("parent").document(user!.uid).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
            
            // 로그인 화면(첫화면)으로 다시 이동
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    func GetPW() {
        if let varTeacherItem = LoginRepository.shared.teacherItem {
            sharedCurrentPW = varTeacherItem.password
        } else if let varStudentItem = LoginRepository.shared.studentItem {
            sharedCurrentPW = varStudentItem.password
        } else {
            db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    // 현재 비밀번호 변수에 DB에 저장된 비밀번호 가져와서 할당
                    sharedCurrentPW = data?["password"] as? String ?? ""
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func GetUserInfoForEditInfo(nameTF : UITextField, emailLabel : UILabel, parentPassword : UITextField, parentPasswordLabel : UILabel) {
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // 이름, 이메일, 학부모 인증용 비밀번호, 사용자의 타입
                nameTF.text = LoginRepository.shared.teacherItem!.name
                emailLabel.text = LoginRepository.shared.teacherItem!.email
                userType = LoginRepository.shared.teacherItem!.type
                sharedCurrentPW = LoginRepository.shared.teacherItem!.password
                let parentPW = data?["parentPW"] as? String ?? ""
                parentPassword.text = parentPW
            } else {
                // 현재 사용자에 해당하는 선생님 문서가 없으면 학생 문서로 다시 검색
                db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        nameTF.text = LoginRepository.shared.studentItem!.name
                        emailLabel.text = LoginRepository.shared.studentItem!.email
                        userType = LoginRepository.shared.studentItem!.type
                        let goal = LoginRepository.shared.studentItem!.goal
                        parentPasswordLabel.text = "목표"
                        parentPassword.text = goal
                    } else {
                        db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let userName = data?["name"] as? String ?? ""
                                nameTF.text = userName
                                let userEmail = data?["email"] as? String ?? ""
                                emailLabel.text = userEmail
                                userType = data?["type"] as? String ?? ""
                                sharedCurrentPW = data?["password"] as? String ?? ""
                                parentPasswordLabel.text = "자녀 휴대전화 번호"
                                let childPhoneNumber = data?["childPhoneNumber"] as? String ?? ""
                                parentPassword.text = childPhoneNumber
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func SaveTeacherInfos(name : String, password : String , parentPW : String) {
        // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
        db.collection("teacher").document(Auth.auth().currentUser!.uid).updateData([
            "name": name,
            "password": password,
            "parentPW": parentPW
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        LoginRepository.shared.teacherItem!.name = name
        LoginRepository.shared.teacherItem!.password = password
    }
    
    func SaveStudentInfos(name : String, password : String , parentPassword : UITextField) {
        // 타입과 이름, 이메일, 비밀번호, 나이, uid 등을 저장
        db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
            "name": name,
            "password": password,
            "goal": parentPassword.text!
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
        LoginRepository.shared.studentItem!.name = name
        LoginRepository.shared.studentItem!.password = password
        LoginRepository.shared.studentItem!.goal = parentPassword.text!
    }
    
    func SaveParentInfos (name : String, password : String, childPhoneNumber : String) {
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
            "name": name,
            "password": password,
            "childPhoneNumber": childPhoneNumberWithDash
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
}
