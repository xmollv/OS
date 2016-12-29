//
//  Location.swift
//  OS
//
//  Created by Xavi Moll on 29/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import Foundation

struct Location {
    
    var name: String
    var lat: Double
    var lon: Double
    
    init?(dict: Dictionary<String,Any>) {
        guard let name = dict["name"] as? String,
            let geometry = dict["geometry"] as? [String:Any]
        else { return nil }
        
        guard let location = geometry["location"] as? [String:Any] else { return nil }
        guard let lat = location["lat"] as? Double,
            let lon = location["lng"] as? Double
        else { return nil }
        
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}
