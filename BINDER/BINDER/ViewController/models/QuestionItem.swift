//
//  QuestionItem.swift
//  BINDER
//
//  Created by 하유림 on 2021/12/11.
//

import Foundation

struct QuestionItem: Decodable {
    
    let studentName: String
    let subjectName : String
    let classColor : String
    let email : String
    
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
