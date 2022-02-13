//
//  QuestionListItem.swift
//  BINDER
//
//  Created by 하유림 on 2022/02/09.
//

import Foundation

struct QuestionListItem : Decodable {
    
    // 변수 선언
    let title: String         // 질문 제목
    let answerCheck: Bool           // (true: 답변 완료, false: 답변 대기)
    let imgURL: String              // 이미지 URL
    let email : String              // 이메일
    let questionContent : String    // 질문 내용
    
    init(title : String, answerCheck : Bool, imgURL : String, questionContent: String, email : String)
    {
        self.title = title
        self.answerCheck = answerCheck
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
