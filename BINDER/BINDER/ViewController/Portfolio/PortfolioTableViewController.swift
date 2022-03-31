//
//  PortfolioTableViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/22.
//

import UIKit
import Firebase
import Kingfisher

// 포트폴리오 정보 뷰 컨트롤러 (tableview 활용)
class PortfolioTableViewController: UIViewController {
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var portfolioTableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    
    var infos: [String] = []
    var isShowMode: Bool = false
    var showModeEmail: String = ""
    var isShowOK: Bool = false
    var content: [String] = []
    
    var teacherUid: String = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView 관련 delegate, dataSource 처리
        portfolioTableView.delegate = self
        portfolioTableView.dataSource = self
        
        // TableView 분리선 없애기
        portfolioTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo() // 유저 정보 가져오기
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        LoadingHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingHUD.hide()
        }
        
        self.portfolioTableView.reloadData() // tableview 다시 그려주기
    }
    
    @IBAction func BackButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil) // 이전 화면 보이도록 하기
    }
    
    // 유저 정보 가져오기
    func getUserInfo(){
        if (isShowMode == true) { /// 포트폴리오 조회인 경우
            self.editBtn.isHidden = true // 수정 버튼 숨기기
            self.db.collection("teacher").whereField("email", isEqualTo: self.showModeEmail).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.teacherName.text = document.data()["name"] as? String ?? ""
                        self.teacherEmail.text = document.data()["email"] as? String ?? ""
                        let profile = document.data()["profile"] as? String ?? ""
                        let uid = document.data()["uid"] as? String ?? ""
                        self.teacherUid = uid
                        
                        self.infos.removeAll() // 원래 있는 제목 정보들 모두 지우기
                        
                        let docRef = self.db.collection("teacher").document(uid).collection("Portfolio").document("portfolio")
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                
                                let eduText = data?["eduHistory"] as? String ?? "" // 학력 정보
                                let classText = data?["classMethod"] as? String ?? "" // 수업 방식
                                let extraText = data?["extraExprience"] as? String ?? "" // 과외 경력
                                let time = data?["time"] as? String ?? "" // 과외 시간
                                let contact = data?["contact"] as? String ?? "" // 연락 수단
                                let manage = data?["manage"] as? String ?? "" // 학생 관리 방법
                                
                                if (eduText != "") {
                                    self.infos.append("학력사항")
                                }
                                if (classText != "") {
                                    self.infos.append("수업 방식")
                                }
                                if (extraText != "") {
                                    self.infos.append("과외 경력")
                                }
                                if (time != "") {
                                    self.infos.append("과외 시간")
                                }
                                if (contact != "") {
                                    self.infos.append("연락 수단")
                                }
                                if (manage != "") {
                                    self.infos.append("학생 관리 방법")
                                }
                                self.infos.append("선생님 평가")
                            }
                        }
                        
                        self.teacherImage.kf.setImage(with: URL(string: profile)!)
                        self.teacherImage.makeCircle()
                    }
                }
            }
        } else {
            self.infos.removeAll()
            let docRef = db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("Portfolio").document("portfolio")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let eduText = data?["eduHistory"] as? String ?? ""
                    let classText = data?["classMethod"] as? String ?? ""
                    let extraText = data?["extraExprience"] as? String ?? ""
                    let time = data?["time"] as? String ?? ""
                    let contact = data?["contact"] as? String ?? ""
                    let manage = data?["manage"] as? String ?? ""
                    
                    if (eduText != "") {
                        self.infos.append("학력사항")
                    }
                    if (classText != "") {
                        self.infos.append("수업 방식")
                    }
                    if (extraText != "") {
                        self.infos.append("과외 경력")
                    }
                    if (time != "") {
                        self.infos.append("과외 시간")
                    }
                    if (contact != "") {
                        self.infos.append("연락 수단")
                    }
                    if (manage != "") {
                        self.infos.append("학생 관리 방법")
                    }
                    self.infos.append("선생님 평가")
                }
            }
            
            self.db.collection("teacher").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let name = data?["name"] as? String ?? ""
                    self.teacherName.text = name
                    let email = data?["email"] as? String ?? ""
                    self.teacherEmail.text = email
                    let profile = document.data()!["profile"] as? String ?? ""
                    self.teacherImage.kf.setImage(with: URL(string: profile)!)
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

extension PortfolioTableViewController: UITableViewDelegate, UITableViewDataSource {
    /// 테이블 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == infos.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlusPortfolioCell")! as! PlusPortfolioCell
            if (indexPath.row == 7 || self.isShowMode == true) { // 총 7개의 정보가 모두 차거나 포트폴리오 조회인 경우
                cell.isHidden = true // 정보 추가 셀 숨기기
            } else {
                cell.isHidden = false
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioDefaultCell")! as! PortfolioDefaultCell
            if Auth.auth().currentUser?.uid != nil { // 현재 사용자의 uid가 nil이 아니면
                self.teacherUid = Auth.auth().currentUser!.uid // self.teacherUid 를 설정
            }
            
            let docRef = db.collection("teacher").document(self.teacherUid).collection("Portfolio").document("portfolio")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    let eduText = data?["eduHistory"] as? String ?? ""
                    let classText = data?["classMethod"] as? String ?? ""
                    let extraText = data?["extraExprience"] as? String ?? ""
                    let time = data?["time"] as? String ?? ""
                    let contact = data?["contact"] as? String ?? ""
                    let manage = data?["manage"] as? String ?? ""
                    let portfolioShow = data?["portfolioShow"] as? String ?? ""
                    
                    if self.infos[indexPath.row] == "연락 수단" {
                        cell.content.text = contact
                    } else if self.infos[indexPath.row] == "학력사항" {
                        cell.content.text = eduText
                    } else if self.infos[indexPath.row] == "수업 방식" {
                        cell.content.text = classText
                    } else if self.infos[indexPath.row] == "과외 경력" {
                        cell.content.text = extraText
                    } else if self.infos[indexPath.row] == "선생님 평가" {
                        cell.content.text = "등록된 선생님 평가가 없습니다." // 연결 필요
                    } else if self.infos[indexPath.row] == "과외 시간" {
                        cell.content.text = time
                    } else if self.infos[indexPath.row] == "학생 관리 방법" {
                        cell.content.text = manage
                    }
                    
                    if (portfolioShow == "Off" && self.isShowMode == true) {
                        let message = "비공개 설정 되어있습니다."
                        if self.infos[indexPath.row] == "연락 수단" {
                            cell.content.text = message
                        } else if self.infos[indexPath.row] == "학력사항" {
                            cell.content.text = message
                        } else if self.infos[indexPath.row] == "수업 방식" {
                            cell.content.text = message
                        } else if self.infos[indexPath.row] == "과외 경력" {
                            cell.content.text = message
                        } else if self.infos[indexPath.row] == "선생님 평가" {
                            cell.content.text = message
                        } else if self.infos[indexPath.row] == "과외 시간" {
                            cell.content.text = message
                        } else if self.infos[indexPath.row] == "학생 관리 방법" {
                            cell.content.text = message
                        }
                    }
                    cell.title.text = self.infos[indexPath.row]
                    
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
            
            return cell
        }
    }
    
    /// didDelectRowAt: 셀 전체 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 플러스 row
        if indexPath.row == infos.count {
            performSegue(withIdentifier: "addPortfolioItemSegue", sender: nil)
        }
    }
}
