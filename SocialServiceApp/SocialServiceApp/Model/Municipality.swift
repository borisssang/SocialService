//
//  Municipality.swift
//  SocialServiceApp
//
//  Created by Boris Angelov on 10.03.19.
//  Copyright © 2019 Boris Angelov. All rights reserved.
//

import Foundation
import CoreLocation

class Municipality{
    
    private var name: String?
    private var location: CLLocationCoordinate2D?
    
    init(name: String, location: CLLocationCoordinate2D){
            self.name = name
            self.location = location
    }
    
    func getLocation() -> CLLocationCoordinate2D?{
        return location
    }
    
    //TODO: send form to the municipality
    func sendForm(form: FormData){
        
    }
}

extension CLLocationCoordinate2D {
    
    func liesInsideRegion(region:[CLLocationCoordinate2D]) -> Bool {
        
        var liesInside = false
        var i = 0
        var j = region.count-1
        
        while i < region.count {
            
            guard let iCoordinate = region[safe:i] else {break}
            guard let jCoordinate = region[safe:j] else {break}
            
            if (iCoordinate.latitude > self.latitude) != (jCoordinate.latitude > self.latitude) {
                if self.longitude < (iCoordinate.longitude - jCoordinate.longitude) * (self.latitude - iCoordinate.latitude) / (jCoordinate.latitude-iCoordinate.latitude) + iCoordinate.longitude {
                    liesInside = !liesInside
                }
            }
            
            i += 1
            j = i+1
        }
        
        return liesInside
    }
}
extension MutableCollection {
    subscript (safe index: Index) -> Iterator.Element? {
        get {
            guard startIndex <= index && index < endIndex else { return nil }
            return self[index]
        }
        set(newValue) {
            guard startIndex <= index && index < endIndex else { print("Index out of range."); return }
            guard let newValue = newValue else { print("Cannot remove out of bounds items"); return }
            self[index] = newValue
        }
    }
}
