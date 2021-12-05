//
//  number.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/21.
//

import Foundation

class UserNumber {
    static let shared = UserNumber()
    
    var number: Int?
    
    private init() { }
}
