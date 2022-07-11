//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

public struct TeacherItem: Decodable {
    
    var email: String
    var name: String
    var password: String
    var profile: String
    let type: String
    let uid: String
    
    init(email: String, name: String, password: String, profile: String, type: String, uid: String) {
        self.email = email
        self.name = name
        self.password = password
        self.profile = profile
        self.type = type
        self.uid = uid
    }
}

extension TeacherItem: Equatable {
    public static func == (lhs: TeacherItem, rhs: TeacherItem) -> Bool {
        return lhs.email == rhs.email
    }
}
