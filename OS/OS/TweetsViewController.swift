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
    var tweets = [Tweet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadRecentTweets()
        
    }
    
    private func downloadRecentTweets() {
        
        let headers = ["Authorization":"OAuth oauth_consumer_key=\"DC0sePOBbQ8bYdC8r4Smg\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1483204579\",oauth_nonce=\"2180899013\",oauth_version=\"1.0\",oauth_token=\"815244804485283842-EJ7qtrT0EVElmbkIAAksLrI2T4kdDYO\",oauth_signature=\"eSUusclOOHsA2WCElz9i2OIvAvQ%3D\""]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        networkManager.fetchDataFrom(serverUrl: "https://api.twitter.com/1.1/search/tweets.json?q=meat", headers: headers) { [weak weakSelf = self] result in
            switch result {
            case .success(let JSON):
                if let jsonParsed = JSON as? [String: Any] {
                    if let tweets = jsonParsed["statuses"] as? [[String:Any]] {
                        for tweet in tweets {
                            if let tweetObject = Tweet(dict: tweet) {
                                weakSelf?.tweets.append(tweetObject)
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

extension TweetsViewController: NetworkManagerClient {
    func set(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
}
