//
//  QuestionItem.swift
//  BINDER
//
//  Created by 하유림 on 2021/12/11.
//

import Foundation

struct QuestionItem: Decodable {
    
    // 변수
    let userName: String        // 학생 이름
    let subjectName : String    // 과목 이름
    let classColor : String     // 수업 색상
    let email : String          // 이메일
    let index: Int              // 인덱스
    
    init(userName : String, subjectName : String, classColor : String, email : String, index: Int) {
        self.userName = userName
        self.subjectName = subjectName
        self.classColor = classColor
        self.email = email
        self.index = index
    }
}

extension QuestionItem: Equatable {
    static func == (lhs: QuestionItem, rhs: QuestionItem) -> Bool {
        return lhs.email == rhs.email
    }
}
