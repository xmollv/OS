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
        // We have to percetnage encode the query or the API will not accept it
        textToQuery = textToDisplay.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        
        downloadRecentTweets()
    }
    
    private func downloadRecentTweets() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // ALERT: This 'Authorization' token has been extracted from the request performed in the Twitter console 
        // after signing in with a dummy account using the OAuth autentication method.
        // https://apigee.com/embed/console/twitter?req=%7B%22resource%22%3A%22search_tweets%22%2C%22params%22%3A%7B%22query%22%3A%7B%22q%22%3A%22meat%20is%20healthy%22%7D%2C%22template%22%3A%7B%7D%2C%22headers%22%3A%7B%7D%2C%22body%22%3A%7B%22attachmentFormat%22%3A%22mime%22%2C%22attachmentContentDisposition%22%3A%22form-data%22%7D%7D%2C%22verb%22%3A%22get%22%7D
        // This way you should not have to auth with your twitter account and it should just work
        // This would never ship in a production app, but the overhead of implementing OAuth and having
        // to make you sign in with your credentials was overkill for this test
        
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
