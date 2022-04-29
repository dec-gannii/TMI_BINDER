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
                    db.collection("student").document(Auth.auth().currentUser!.uid).getDocument { (document, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                            failure(err)
                        } else {
                            guard let doc = document, doc.exists else {
                                print(">>>>> 해당하는 학생 존재하지 않음")
                                
                                db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                        failure(err)
                                    } else {
                                        guard let doc = document, doc.exists else {
                                            print(">>>>> 해당하는 학부모 존재하지 않음")
                                            return
                                        }
                                        let parentDt = doc.data()!
                                        let email = parentDt["email"] as? String ?? ""
                                        let name = parentDt["name"] as? String ?? ""
                                        let password = parentDt["password"] as? String ?? ""
                                        let childPhoneNumber = parentDt["childPhoneNumber"] as? String ?? ""
                                        var profile = parentDt["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                                        
                                        /// 성공 알림
                                        completion()
                                        return
                                    }
                                }
                                
                                return
                            }
                            let studentDt = doc.data()!
                            let age = studentDt["age"] as? Int ?? 0
                            let email = studentDt["email"] as? String ?? ""
                            let name = studentDt["name"] as? String ?? ""
                            let password = studentDt["password"] as? String ?? ""
                            let phone = studentDt["phone"] as? String ?? ""
                            let profile = studentDt["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                            let goal = studentDt["goal"] as? String ?? ""
                            self.studentItem = StudentItem(age: age, email: email, goal: goal, name: name, password: password, phone: phone, profile: profile)
                            
                            /// 성공 알림
                            completion()
                            return
                        }
                    }
                    return
                }
                
                let teacherDt = doc.data()!
                let age = teacherDt["age"] as? Int ?? 0
                let email = teacherDt["email"] as? String ?? ""
                let name = teacherDt["name"] as? String ?? ""
                let password = teacherDt["password"] as? String ?? ""
                let phone = teacherDt["phone"] as? String ?? ""
                let profile = teacherDt["profile"] as? String ?? "https://ifh.cc/g/Lt9Ip8.png"
                self.teacherItem = TeacherItem(age: age, email: email, name: name, password: password, phone: phone, profile: profile)
                
                /// 성공 알림
                completion()
            }
        }
    }
}
