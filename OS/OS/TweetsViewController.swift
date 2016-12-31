//
//  TweetsViewController.swift
//  OS
//
//  Created by Xavi Moll on 25/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var queryText: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var networkManager: NetworkManager!
    var tweets = [Tweet]()
    let textToDisplay = "meat is healthy"
    var textToQuery: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        titleLabel.text = NSLocalizedString("Tweets.Title", comment: "This title appears above the tweets.")
        queryText.text = textToDisplay
        textToQuery = textToDisplay.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        
        downloadRecentTweets()
    }
    
    private func downloadRecentTweets() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let headers = ["Authorization":"OAuth oauth_consumer_key=\"DC0sePOBbQ8bYdC8r4Smg\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1483207824\",oauth_nonce=\"317047819\",oauth_version=\"1.0\",oauth_token=\"815244804485283842-EJ7qtrT0EVElmbkIAAksLrI2T4kdDYO\",oauth_signature=\"TwMnhogoCF4vbL62k8JkzsvXby4%3D\""]
        
        networkManager.fetchDataFrom(serverUrl: "https://api.twitter.com/1.1/search/tweets.json?q=\(textToQuery!)", headers: headers) { [weak weakSelf = self] result in
            switch result {
            case .success(let JSON):
                if let jsonParsed = JSON as? [String: Any] {
                    if let tweets = jsonParsed["statuses"] as? [[String:Any]] {
                        for tweet in tweets {
                            if let tweetObject = Tweet(dict: tweet) {
                                weakSelf?.tweets.append(tweetObject)
                            }
                        }
                        DispatchQueue.main.async {
                            weakSelf?.tableView.reloadData()
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

extension TweetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TweetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let tweet = tweets[indexPath.row]
        cell.tweetTextLabel.text = tweet.text
        return cell
    }
}
