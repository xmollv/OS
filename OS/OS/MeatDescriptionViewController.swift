//
//  FirstViewController.swift
//  OS
//
//  Created by Xavi Moll on 25/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import UIKit

class MeatDescriptionViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var firstImage: UIImageView!
    @IBOutlet var secondImage: UIImageView!
    @IBOutlet var thirdImage: UIImageView!
    @IBOutlet var fourthImage: UIImageView!
    
    var networkManager: NetworkManager!
    private let flickrQuery = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=13f0e8a7074cc68196840bef96520318&text=meat&safe_search=1&content_type=1&media=photos&per_page=4&format=json&nojsoncallback=1"
    private var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        downloadDataFromFlickr()
    }
    
    private func downloadDataFromFlickr() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // I'm using weak self to avoid retain cycles
        networkManager.fetchDataFrom(serverUrl: flickrQuery, headers: nil) { [weak weakSelf = self] result in
            switch result {
            case .success(let JSON):
                if let jsonDict = JSON as? [String: Any] {
                    if let photos = jsonDict["photos"] as? [String: Any] {
                        if let photo = photos["photo"] as? [[String: Any]] {
                            for elem in photo {
                                if let photoModeled = Photo(dict: elem) {
                                    weakSelf?.photos.append(photoModeled)
                                }
                            }
                            // Every UI update must be done in the main thread
                            DispatchQueue.main.async {
                                weakSelf?.populateImages()
                            }
                        }
                    }
                } else {
                    print("Error parsing the JSON to a Dictionary")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    private func populateImages() {
        if !photos.isEmpty && photos.count == 4 {
            firstImage.setImage(photo: photos[0])
            secondImage.setImage(photo: photos[1])
            thirdImage.setImage(photo: photos[2])
            fourthImage.setImage(photo: photos[3])
        } else {
            print("Not enought photos. Try to download a few more. The query only downloads 4 images.")
        }
    }
}

extension MeatDescriptionViewController: NetworkManagerClient {
    func set(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
}

// Resign the first responder for the textFields to hide the keyboard
extension MeatDescriptionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// Handle the keyboard when appears/disappears: http://stackoverflow.com/a/31124676/5683397
extension MeatDescriptionViewController {
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

extension UIImageView {
    // Basic setup to display a photo. This should be cached and should display an spinner while
    // it's downloading the data
    func setImage(photo: Photo) {
        if let url = URL(string: photo.url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {
                    self.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}
