//
//  ParentItem.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/13.
//

struct ParentItem: Decodable {
    let name: String
    let email: String
    let childPhoneNumber: String
    let password: String
    var profile: String
    
    init(email: String, childPhoneNumber: String, name: String, password: String, profile: String) {
        self.email = email
        self.childPhoneNumber = childPhoneNumber
        self.name = name
        self.password = password
        self.profile = profile
    }
}

extension ParentItem: Equatable {
    static func == (lhs: ParentItem, rhs: ParentItem) -> Bool {
        return lhs.email == rhs.email
    }
}

