//
//  HomeStudentLinkIcon.swift
//  BINDER
//
//  Created by 김가은 on 2022/01/24.
//

struct HomeStudentLinkIconItem: Decodable {
    
    // 클래스 정보
    let email: String // 학생 이메일
    let name: String // 학생 이름
    let subject: String // 과목
    
    init(email: String, name: String, subject: String) {
        self.email = email
        self.name = name
        self.subject = subject
    }
    
}

extension HomeStudentLinkIconItem: Equatable {
    static func == (lhs: HomeStudentLinkIconItem, rhs: HomeStudentLinkIconItem) -> Bool {
        return lhs.email == rhs.email
    }
}
