//
//  LocationManager.swift
//  babble
//
//  Created by 박정헌 on 2/17/24.
//

import Foundation
import CoreLocation
class LocationManager:NSObject, ObservableObject,CLLocationManagerDelegate{
    let manager = CLLocationManager()
    @Published
    var longitude = 0.0
    @Published
    var latitude = 0.0
    init(latitude:Double,longitude:Double){
        super.init()
        self.longitude = longitude
        self.latitude = latitude
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        startUpdateLocation()
      
    }
    func startUpdateLocation() {
        if manager.authorizationStatus != .authorizedWhenInUse {
            manager.requestWhenInUseAuthorization()
        }
        else {
            manager.startUpdatingLocation()
        }
    }
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        
        latitude = locations[0].coordinate.latitude
        longitude = locations[0].coordinate.longitude
         print(latitude)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latitude = -1000.0
        longitude = -1000.0
    }
}
