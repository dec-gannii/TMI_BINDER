//
//  QuestionItem.swift
//  BINDER
//
//  Created by 하유림 on 2021/12/11.
//

import Foundation

struct QuestionItem: Decodable {
    
    let studentName: String
    let subject : String
    let subjectColor : String
    let email : String
    
    init(studentName : String, subject : String, subjectColor : String, email : String) {
        self.studentName = studentName
        self.subject = subject
        self.subjectColor = subjectColor
        self.email = email
    }
}

extension QuestionItem: Equatable {
    static func == (lhs: QuestionItem, rhs: QuestionItem) -> Bool {
        return lhs.email == rhs.email
    }
}
