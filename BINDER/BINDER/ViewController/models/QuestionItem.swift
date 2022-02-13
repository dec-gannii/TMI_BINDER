//
//  QuestionItem.swift
//  BINDER
//
//  Created by 하유림 on 2021/12/11.
//

import Foundation

struct QuestionItem: Decodable {
    
    // 변수
    let studentName: String     // 학생 이름
    let subjectName : String    // 과목 이름
    let classColor : String     // 수업 색상
    let email : String          // 이메일
    
    init(studentName : String, subjectName : String, classColor : String, email : String) {
        self.studentName = studentName
        self.subjectName = subjectName
        self.classColor = classColor
        self.email = email
    }
}

extension QuestionItem: Equatable {
    static func == (lhs: QuestionItem, rhs: QuestionItem) -> Bool {
        return lhs.email == rhs.email
    }
}
