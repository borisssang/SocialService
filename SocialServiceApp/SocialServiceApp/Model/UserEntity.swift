//
//  UserEntity.swift
//  Фандъкова
//
//  Created by Boris Angelov on 15.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import Foundation

class UserEntity{
    
    var name: String?
    var password: String?
    var userEmail: String?
    var userPhone: Int?
    
    init(first: String, pas: String, email: String, phone: Int){
        name = first
        password = pas
        userEmail = email
        userPhone = phone
    }
}
