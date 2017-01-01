//
//  Photo.swift
//  OS
//
//  Created by Xavi Moll on 26/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import Foundation

struct Photo {
    var farm: Int
    var server: String
    var id: String
    var secret: String
    var url: String
    
    init?(dict: Dictionary<String,Any>) {
        guard let farm = dict["farm"] as? Int,
                let server = dict["server"] as? String,
                let id = dict["id"] as? String,
                let secret = dict["secret"] as? String
        else { return nil }
        
        self.farm = farm
        self.server = server
        self.id = id
        self.secret = secret
        self.url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}
