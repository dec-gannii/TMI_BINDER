//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

public struct StudentItem: Decodable {
    
    var email: String
    var goal: String
    var name: String
    var password: String
    var phone: String
    var profile: String
    let type: String
    let uid: String
    
    init(email: String, goal: String, name: String, password: String, phone: String, profile: String, type: String, uid: String) {
        self.email = email
        self.goal = goal
        self.name = name
        self.password = password
        self.phone = phone
        self.profile = profile
        self.type = type
        self.uid = uid
    }
    
}

extension StudentItem: Equatable {
    public static func == (lhs: StudentItem, rhs: StudentItem) -> Bool {
        return lhs.email == rhs.email
    }
}
