//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//
import Foundation
import Firebase

class LoginRepository {
    
    static let shared = LoginRepository()
    
    var teacherItem: TeacherItem?
    var studentItem: StudentItem?
    
    init() {
    }
    
    func doLogin(completion: @escaping () -> Void, failure: @escaping ((_ error: Error?) -> Void)) {
        let db = Firestore.firestore()
        db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                failure(err)
            } else {
                guard let doc = document, doc.exists else {
                    print(">>>>> 해당하는 선생님 존재하지 않음")
                    //                    failure(err)
                    //                    return
                    db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                            failure(err)
                        } else {
                            guard let doc = document, doc.exists else {
                                print(">>>>> 해당하는 학생 존재하지 않음")
                                return
                            }
                            let studnentDt = doc.data()!
                            let age = studnentDt["Age"] as? Int ?? 0
                            let email = studnentDt["Email"] as? String ?? ""
                            let name = studnentDt["Name"] as? String ?? ""
                            let password = studnentDt["Password"] as? String ?? ""
                            let phone = studnentDt["Phone"] as? String ?? ""
                            let profile = studnentDt["Profile"] as? String ?? ""
                            let goal = studnentDt["Goal"] as? String ?? ""
                            self.studentItem = StudentItem(age: age, email: email, goal: goal, name: name, password: password, phone: phone, profile: profile)
                            
                            /// 성공 알림
                            completion()
                            return
                        }
                    }
                    return
                }
                
                let teacherDt = doc.data()!
                let age = teacherDt["Age"] as? Int ?? 0
                let email = teacherDt["Email"] as? String ?? ""
                let name = teacherDt["Name"] as? String ?? ""
                let password = teacherDt["Password"] as? String ?? ""
                let phone = teacherDt["Phone"] as? String ?? ""
                let profile = teacherDt["Profile"] as? String ?? ""
                self.teacherItem = TeacherItem(age: age, email: email, name: name, password: password, phone: phone, profile: profile)
                
                /// 성공 알림
                completion()
            }
        }
    }
}
