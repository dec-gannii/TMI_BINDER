//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

struct TeacherItem: Decodable {
    
    let age: Int
    let email: String
    let name: String
    let password: String
    let phone: String
    let profile: String
    
    init(age: Int, email: String, name: String, password: String, phone: String, profile: String) {
        self.age = age
        self.email = email
        self.name = name
        self.password = password
        self.phone = phone
        self.profile = profile
    }
}

extension TeacherItem: Equatable {
    static func == (lhs: TeacherItem, rhs: TeacherItem) -> Bool {
        return lhs.email == rhs.email
    }
}
