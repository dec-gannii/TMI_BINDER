//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

struct ClassItem: Decodable {
    
    // 클래스 정보
    let email: String // 학생 이메일
    let name: String // 학생 이메일
    let goal: String // 학생 목표
    let subject: String // 과목
    let currentCnt: Int // 현재 횟수
    let totalCnt: Int // 전체 횟수
    let circleColor: String // 컬러 색상
    let recentDate: String // 최근 과외 시간
    let payType: String // 정산 방식 (회차별 : C, 시간별 : T)
    let payDate: String // 정산일
    let payAmount: String // 정산금액
    let schedule: String // 과외일정
    let repeatYN: String // 반복유무
    
    init(email: String, name: String, goal: String, subject: String, recentDate: String, currentCnt: Int, totalCnt: Int, circleColor: String, payType: String, payDate: String, payAmount: String, schedule: String, repeatYN: String) {
        self.email = email
        self.name = name
        self.goal = goal
        self.subject = subject
        self.recentDate = recentDate
        self.currentCnt = currentCnt
        self.totalCnt = totalCnt
        self.circleColor = circleColor
        self.payType = payType
        self.payDate = payDate
        self.payAmount = payAmount
        self.schedule = schedule
        self.repeatYN = repeatYN
    }
    
}

extension ClassItem: Equatable {
    static func == (lhs: ClassItem, rhs: ClassItem) -> Bool {
        return lhs.email == rhs.email
    }
}
