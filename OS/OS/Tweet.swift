//
//  Tweet.swift
//  OS
//
//  Created by Xavi Moll on 31/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import Foundation

struct Tweet {
    var text: String
    
    init?(dict: Dictionary<String,Any>) {
        guard let text = dict["text"] as? String else { return nil }
        
        self.text = text
    }
}
