//
//  File.swift
//  OS
//
//  Created by Xavi Moll on 31/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import Foundation
import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet var tweetTextLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tweetTextLabel.text = nil
    }
}
