//
//  AnsweredQuestionListItem.swift
//  BINDER
//
//  Created by 하유림 on 2022/03/01.
//

import Foundation

struct QuestionAnsweredListItem : Decodable {
    
    // 변수 선언
    let title: String         // 질문 제목
    let answerCheck: Bool           // (true: 답변 완료, false: 답변 대기)
    let imgURL: String             // 이미지 URL
    let email : String              // 이메일
    let questionContent : String    // 질문 내용
    let index : String
    
    init(title : String, answerCheck : Bool, imgURL : String, questionContent: String, email : String, index: String)
    {
        self.title = title
        self.answerCheck = answerCheck
        self.questionContent = questionContent
        self.imgURL = imgURL
        self.email = email
        self.index = index
    }
}

extension QuestionAnsweredListItem: Equatable {
    static func == (lhs: QuestionAnsweredListItem, rhs: QuestionAnsweredListItem) -> Bool {
        return lhs.email == rhs.email
    }
}
