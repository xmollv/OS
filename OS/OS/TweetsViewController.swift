//
//  TweetsViewController.swift
//  OS
//
//  Created by Xavi Moll on 25/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    
    var networkManager: NetworkManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headers = ["Authorization":"OAuth oauth_consumer_key=\"DC0sePOBbQ8bYdC8r4Smg\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1483204579\",oauth_nonce=\"2180899013\",oauth_version=\"1.0\",oauth_token=\"815244804485283842-EJ7qtrT0EVElmbkIAAksLrI2T4kdDYO\",oauth_signature=\"eSUusclOOHsA2WCElz9i2OIvAvQ%3D\""]
        
        networkManager.fetchDataFrom(serverUrl: "https://api.twitter.com/1.1/search/tweets.json?q=meat", headers: headers) { result in
            switch result {
            case .success(let JSON):
                dump(JSON)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension TweetsViewController: NetworkManagerClient {
    func set(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
}
