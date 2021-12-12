//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

import UIKit
import Kingfisher
import Firebase

class MyClassVC: BaseVC {
    
    /// 선생님 이름 변수
    @IBOutlet weak var teacherName: UILabel!
    
    /// 선생님 이메일 변수
    @IBOutlet weak var teacherEmail: UILabel!
    
    /// 선생님 사진 변수
    @IBOutlet weak var teacherImage: UIImageView!
    
    /// 학생 리스트
    @IBOutlet weak var studentTV: UITableView!
    
    /// 수업 변수 배열
    var classItems: [ClassItem] = []
    
    // MARK: - 라이프 사이클
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기화
        teacherName.text = ""
        teacherEmail.text = ""
        
        // 선생님 정보가져오기
        setTeacherInfo()
    }
    
    /// segue를 호출할 때, 데이터를 넘기고 싶은 경우에 사용
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // delegate 전달
        if let resultVC = segue.destination as? AddStudentVC {
            resultVC.delegate = self
        }
        
    }
    
    // MARK: - 기능
    
    /// 선생님 셋팅
    func setTeacherInfo() {
        LoginRepository.shared.doLogin {
            /// 가져오는 시간 걸림
            self.teacherName.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
            self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
            
            let url = URL(string: LoginRepository.shared.teacherItem!.profile)
            self.teacherImage.kf.setImage(with: url)
            self.teacherImage.makeCircle()
            
            /// 클래스 가져오기
            self.setMyClasses()
        } failure: { error in
            self.showDefaultAlert(msg: "")
        }
        /// 클로저, 리스너
    }
    
    // 내 수업 가져오기
    func setMyClasses() {
        let db = Firestore.firestore()
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
                self.showDefaultAlert(msg: "클래스를 찾는 중 에러가 발생했습니다.")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                
                /// 조회하기 위해 원래 있던 것 들 다 지움
                self.classItems.removeAll()
                
                
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    
                    /// document.data()를 통해서 값 받아옴, data는 dictionary
                    let classDt = document.data()
                    
                    /// nil값 처리
                    let email = classDt["email"] as? String ?? ""
                    let name = classDt["name"] as? String ?? ""
                    let goal = classDt["goal"] as? String ?? ""
                    let subject = classDt["subject"] as? String ?? ""
                    let currentCnt = classDt["currentCnt"] as? Int ?? 0
                    let totalCnt = classDt["totalCnt"] as? Int ?? 0
                    let circleColor = classDt["circleColor"] as? String ?? "026700"
                    let recentDate = classDt["recentDate"] as? String ?? ""
                    let payType = classDt["payType"] as? String ?? ""
                    let payDate = classDt["payDate"] as? String ?? ""
                    let payAmount = classDt["payAmount"] as? String ?? ""
                    let schedule = classDt["schedule"] as? String ?? ""
                    let repeatYN = classDt["repeatYN"] as? String ?? ""
                    let item = ClassItem(email: email, name: name, goal: goal, subject: subject, recentDate: recentDate, currentCnt: currentCnt, totalCnt: totalCnt, circleColor: circleColor, payType: payType, payDate: payDate, payAmount: payAmount, schedule: schedule, repeatYN: repeatYN)
                    
                    /// 모든 값을 더한다.
                    self.classItems.append(item)
                }
                
                /// UITableView를 reload 하기
                self.studentTV.reloadData()
            }
        }
    }
    
}

// MARK: - 테이블뷰 관련

extension MyClassVC: UITableViewDelegate, UITableViewDataSource {
    
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == classItems.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "add")! as! PlusTableViewCell
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "class")! as! CardTableViewCell
            
            let item:ClassItem = classItems[indexPath.row]
            cell.studentName.text = "\(item.name) 학생 "
            cell.subjectName.text = item.subject
            cell.subjectGoal.text = item.goal
            cell.cntLb.text = "\(item.currentCnt) / \(item.totalCnt)"
            
            cell.classColor.makeCircle()
            if let hex = Int(item.circleColor, radix: 16) {
                cell.classColor.backgroundColor = UIColor.init(rgb: hex)
            } else {
                cell.classColor.backgroundColor = UIColor.red
            }
            
            cell.manageBtn.addTarget(self, action: #selector(onClickManageButton(_:)), for: .touchUpInside)
            cell.manageBtn.tag = indexPath.row
            
            return cell
        }
    }
    
    
    /// 수업관리하기 버튼 클릭
    /// - Parameter sender: 버튼
    @IBAction func onClickManageButton(_ sender: UIButton) {
//        let weekendVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController")
        var index: Int!
        
        let db = Firestore.firestore()
        /// 입력한 이메일과 갖고있는 이메일이 같은지 확인
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").whereField("index", isEqualTo: sender.tag)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                        return
                    }
                    
                    guard let weekendVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailClassViewController") as? DetailClassViewController else { return }
                    
                    weekendVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                    weekendVC.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                    /// first : 여러개가 와도 첫번째 것만 봄.
                    let studentDt = snapshot.documents.first!.data()
                    index = studentDt["index"] as? Int ?? 0
//                    let name = studentDt["name"] as? String ?? ""
//                    print ("index : \(index)")
                    weekendVC.userIndex = index
                    
                    self.present(weekendVC, animated: true, completion: nil)
                }
            }
        
        print("클릭됨 : \(sender.tag)")
    }
    
    /// didDelectRowAt: 셀 전체 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 플러스 row
        if indexPath.row == classItems.count {
            performSegue(withIdentifier: "addStudentSegue", sender: nil)
        }
        // 학생 row
        else {
            // 아무것도 하지 않음
        }
    }
}

// MARK: - 학생 추가 후 처리

extension MyClassVC: AddStudentDelegate {
    
    /// 학생 추가가 완료된 경우
    func onSuccess() {
        setMyClasses()
    }
    
}
