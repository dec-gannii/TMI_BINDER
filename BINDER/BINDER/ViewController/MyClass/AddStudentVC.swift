//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit
import Firebase

class AddStudentVC: BaseVC {

    @IBOutlet weak var emailTf: UITextField!
    
    weak var delegate: AddStudentDelegate?
    
    // MARK: - 라이프 사이클
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 키보드 띄우기
        emailTf.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let resultVC = segue.destination as? ClassInfoVC, let item = sender as? StudentItem {
            resultVC.studentItem = item
            resultVC.delegate = delegate
        }
        
    }
    
    // MARK: - 기능
    
    /// 학생 정보 가져오기
    /// - Parameter email: 학생 이메일
    func searchStudent(email: String) {
        let db = Firestore.firestore()
        /// 입력한 이메일과 갖고있는 이메일이 같은지 확인
        db.collection("student").whereField("Email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                    self.showDefaultAlert(msg: "학생을 찾는 중 에러가 발생했습니다.")
                } else {
                    
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        self.showDefaultAlert(msg: "해당하는 학생이 존재하지 않습니다.")
                        return
                    }
                    
                    /// first : 여러개가 와도 첫번째 것만 봄.
                    let studentDt = snapshot.documents.first!.data()
                    let age = studentDt["Age"] as? Int ?? 0
                    let email = studentDt["Email"] as? String ?? ""
                    let goal = studentDt["Goal"] as? String ?? ""
                    let name = studentDt["Name"] as? String ?? ""
                    let password = studentDt["Password"] as? String ?? ""
                    let phone = studentDt["Phone"] as? String ?? ""
                    let profile = studentDt["Profile"] as? String ?? ""
                    let item = StudentItem(age: age, email: email, goal: goal, name: name, password: password, phone: phone, profile: profile)
                    
                    /// 값 넘어가기
                    self.performSegue(withIdentifier: "inputClassSegue", sender: item)
                }
                
                /// 변수 다시 공백으로 바꾸기
                self.emailTf.text = ""
            }
    }
    
    /// 계속하기 버튼 클릭
    /// - Parameter sender: 버튼
    @IBAction func onNext(_ sender: UIButton) {
        /// nil 처리
        guard let email = emailTf.text, !email.isEmpty else {
            showDefaultAlert(msg: "이메일을 입력해주세요.")
            return
        }
        searchStudent(email: email)
    }
    
}
