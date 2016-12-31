//
//  SecondViewController.swift
//  OS
//
//  Created by Xavi Moll on 25/12/2016.
//  Copyright © 2016 Xavi Moll. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet var mapContainer: UIView!
    
    var networkManager: NetworkManager!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: 41.38, longitude: 2.16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: mapContainer.bounds, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the map to the view, hide it until we've got a location update.
        mapContainer.addSubview(mapView)
        mapView.isHidden = true
    }
    
    func placeAutocomplete(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let query = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=meat&location=\(latitude),\(longitude)&radius=50000&key=AIzaSyCuxczot7HjTyWbWpym9NRmcAOHxxzpSGg"
        networkManager.fetchDataFrom(serverUrl: query, headers: nil) { result in
            switch result {
            case .success(let JSON):
                if let jsonParsed = JSON as? [String:Any] {
                    if let results = jsonParsed["results"] as? [[String:Any]] {
                        print("Number of results: \(results.count)")
                        for result in results {
                            if let place = Location(dict: result) {
                                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon))
                                marker.title = place.name
                                marker.map = self.mapView
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        placeAutocomplete(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
}

extension MapViewController: NetworkManagerClient {
    func set(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
}
