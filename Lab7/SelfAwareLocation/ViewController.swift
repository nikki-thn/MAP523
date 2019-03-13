//
//  ViewController.swift
//  SelfAwareLocation
//
//  Created by Nikki on 3/11/19.
//  Copyright © 2019 Nikki. All rights reserved.
//

//******************NOTES************************
//Need to add CoreLocation.Framework from the app to use the library
//Need to add in info.plist "Privacy - Location Always .... & Location When In Usage ...
//Credits: https://stackoverflow.com/questions/24345296/swift-clgeocoder-reversegeocodelocation-completionhandler-closure

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var longDelta = 0.005
    var latDelta = 0.005
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    private var customView: UIView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBAction func zoomOutBtn(_ sender: Any) {
        longDelta -= 0.005
        latDelta -= 0.005
        
        let latitude = userLocation.coordinate.latitude
        let longtitude = userLocation.coordinate.longitude
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }

    @IBOutlet weak var zoomInBtn: UIButton!
    @IBAction func zoomInBtnTouched(_ sender: Any) {
        longDelta += 0.005
        latDelta += 0.005
        
        let latitude = userLocation.coordinate.latitude
        let longtitude = userLocation.coordinate.longitude
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //customView.isHidden = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func detailsBtnTouched(_ sender: Any) {
        displayLocationDetails()
    }

    func displayLocationDetails () {
        
        let geocoder = CLGeocoder()
        print("-> Finding user address...")
        var addressString : String = ""
        
        geocoder.reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            
            if error == nil && placemarks!.count > 0 {
                placemark = placemarks![0] as CLPlacemark
                
                if placemark.subThoroughfare != nil {
                    addressString += placemark.subThoroughfare! + " "
                }
                if placemark.thoroughfare != nil {
                    addressString += placemark.thoroughfare! + ", "
                }
                if placemark.postalCode != nil {
                    addressString += placemark.postalCode! + " "
                }
                if placemark.locality != nil {
                    addressString += placemark.locality! + ", "
                }
                if placemark.administrativeArea != nil {
                    addressString += placemark.administrativeArea! + " "
                }
                if placemark.country != nil {
                    addressString = addressString + placemark.country!
                }
                
            }
            
            print(addressString)
            
            self.setAlertView(address: addressString)

        })
    }
    
    func setAlertView(address: String) {
        let location = """
        Altitude : \(String(self.userLocation.altitude))
        Latitude : \(String(self.userLocation.coordinate.latitude))
        Longtitude : \(String(self.userLocation.coordinate.longitude))
        Speed : \(String(self.userLocation.speed))
        Course : \(String(self.userLocation.course))
        Nearest address:
        \(address)
        """
        
        //show details location on an UIAlertView
        let confirm2 = UIAlertView(title: "Location details", message: location, delegate: nil, cancelButtonTitle: "Close")
        
        //show it
        confirm2.show()
    }
    
    //this func get call as soon as the user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0])
        userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longtitude = userLocation.coordinate.longitude
        
        let longDelta = 0.005
        let latDelta = 0.005
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
}

