//
//  EvaluationItem.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

struct EvaluationItem: Decodable {
    // 클래스 정보
    let email: String // 학생 이메일
    let name: String // 학생 이메일
    let evaluation: String // 학생 평가
    let subject: String // 과목
    let currentCnt: Int // 현재 횟수
    let totalCnt: Int // 전체 횟수
    let circleColor: String // 컬러 색상
    let index: Int // 인덱스
    
    init(email: String, name: String, evaluation: String, currentCnt: Int, totalCnt: Int, circleColor: String, subject: String, index: Int) {
        self.email = email
        self.name = name
        self.subject = subject
        self.evaluation = evaluation
        self.currentCnt = currentCnt
        self.totalCnt = totalCnt
        self.circleColor = circleColor
        self.index = index
    }
}

extension EvaluationItem: Equatable {
    static func == (lhs: EvaluationItem, rhs: EvaluationItem) -> Bool {
        return lhs.email == rhs.email
    }
}
