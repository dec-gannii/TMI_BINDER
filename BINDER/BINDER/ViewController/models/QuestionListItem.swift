//
//  QuestionListItem.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import Foundation

struct QuestionListItem : Decodable {
    
    // 변수 선언
    let subjectName: String
    let answerCheck: Bool // (true: 답변 완료, false: 답변 대기)
    //var background: String
    let imgURL: String
    let email : String
    let questionContent : String
    
    init(subjectName : String, answerCheck : Bool, imgURL : String, questionContent: String, email : String)
    {
        self.subjectName = subjectName
        self.answerCheck = answerCheck
        //self.background = background
        self.questionContent = questionContent
        self.imgURL = imgURL
        self.email = email
    }
}

extension QuestionListItem: Equatable {
    static func == (lhs: QuestionListItem, rhs: QuestionListItem) -> Bool {
        return lhs.email == rhs.email
    }
}
