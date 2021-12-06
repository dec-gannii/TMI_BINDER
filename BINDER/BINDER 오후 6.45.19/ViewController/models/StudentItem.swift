//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

struct StudentItem: Decodable {
    
    let age: Int
    let email: String
    let goal: String
    let name: String
    let password: String
    let phone: String
    
    init(age: Int, email: String, goal: String, name: String, password: String, phone: String) {
        self.age = age
        self.email = email
        self.goal = goal
        self.name = name
        self.password = password
        self.phone = phone
    }
    
}

extension StudentItem: Equatable {
    static func == (lhs: StudentItem, rhs: StudentItem) -> Bool {
        return lhs.email == rhs.email
    }
}
