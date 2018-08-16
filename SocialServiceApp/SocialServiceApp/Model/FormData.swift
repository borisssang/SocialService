//
//  FormData.swift
//  Фандъкова
//
//  Created by Boris Angelov on 14.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class FormData {
    
    private var formUser: UserEntity?
    private var formImage: UIImage?
    private var formAddress: String?
    private var formLocation: CLLocation?
    private var formCategory: String?
    private var formDescription: String?
    
    init(user: UserEntity, image: UIImage, address: String, location: CLLocation, category: String, description: String) {
        formUser = user
        formImage = image
        formAddress = address
        formLocation = location
        formCategory = category
        formDescription = description
    }
}
