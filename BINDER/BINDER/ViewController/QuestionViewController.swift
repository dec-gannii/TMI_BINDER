//
//  QuestionViewController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/11.
//

import UIKit

class QuestionViewController: BaseVC {
    
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherEmail: UILabel!
    @IBOutlet weak var teacherImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    func getUserInfo(){
        LoginRepository.shared.doLogin {
                    /// 가져오는 시간 걸림
                    self.teacherName.text = "\(LoginRepository.shared.teacherItem!.name) 선생님"
                    self.teacherEmail.text = LoginRepository.shared.teacherItem!.email
                    
                    let url = URL(string: LoginRepository.shared.teacherItem!.profile)
                    self.teacherImage.kf.setImage(with: url)
                    self.teacherImage.makeCircle()
                    
                    /// 클래스 가져오기
                    //self.setMyClasses()
                } failure: { error in
                    self.showDefaultAlert(msg: "")
                }
                /// 클로저, 리스너
    }
}
