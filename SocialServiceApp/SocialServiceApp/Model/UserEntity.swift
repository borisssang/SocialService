//
//  UserEntity.swift
//  Фандъкова
//
//  Created by Boris Angelov on 15.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import Foundation

class UserEntity{
    
    private var firstName: String?
    private var lastName: String?
    private var userEmail: String?
    private var userPhone: Int?
    
    init(first: String, last: String, email: String, phone: Int){
        firstName = first
        lastName = last
        userEmail = email
        userPhone = phone
    }
}
