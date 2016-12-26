//
//  FirstViewController.swift
//  OS
//
//  Created by Xavi Moll on 25/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import UIKit

protocol NetworkManagerClient {
    func set(networkManager: NetworkManager)
}

class MeatDescriptionViewController: UIViewController {

    var networkManager: NetworkManager!
    private let flickrQuery = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=a2846448fcd4963259bd4e2f4613f5b2&text=meat&safe_search=1&content_type=1&media=photos&per_page=4&format=json&nojsoncallback=1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        networkManager.fetchDataFrom(serverUrl: flickrQuery) { result in
            switch result {
            case .success(let JSON):
                dump(JSON)
            case .failure(let error):
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

}

extension MeatDescriptionViewController: NetworkManagerClient {
    func set(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
}
