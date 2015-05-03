//
//  LocationManager.swift
//  strv-test
//
//  Created by Milan Horvatovic on 29/04/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit;
import CoreLocation;

@objc protocol LocationManagerDelegate: NSObjectProtocol {
    
    optional func locationManager(locationManager: LocationManager, loadLocation: CLLocation);
    func locationManager(locationManager: LocationManager, didFailWithError: NSError);
    
}

class LocationManager: NSObject, CLLocationManagerDelegate {
   
    weak var delegate: LocationManagerDelegate?;
    
    private var locationManagerInstance: CLLocationManager;
    private var locatingEnabled: Bool;
    
    func load() {
        LocationManager.sharedInstance;
    }
    
    class var sharedInstance: LocationManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0;
            static var instance: LocationManager? = nil;
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationManager();
        }
        return Static.instance!;
    }
    
    override init() {
        self.locationManagerInstance = CLLocationManager();
        self.locatingEnabled = false;
        
        super.init();
        
        self.locationManagerInstance.delegate = self;
        self.locationManagerInstance.desiredAccuracy = kCLLocationAccuracyBest;
        
        let manager = CLLocationManager();
        if (CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .NotDetermined) {
            self.locationManagerInstance.requestWhenInUseAuthorization();
        }
    }
    
    //  MARK: Delegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let delegate = self.delegate {
            if (delegate.respondsToSelector("locationManager:loadLocation:")) {
                delegate.locationManager!(self, loadLocation: locations.first as! CLLocation);
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if let delegate = self.delegate {
            if (delegate.respondsToSelector("locationManager:didFailWithError:")) {
                delegate.locationManager(self, didFailWithError: error);
            }
        }
    }
    
    //  MARK: Public
    func startLocating() -> Bool {
        if (self.locatingEnabled == false) {
            self.locationManagerInstance.startUpdatingLocation();
            self.locatingEnabled = true;
            return true;
        }
        return false;
    }
    
    func stopLocating() -> Bool {
        if (self.locatingEnabled == true) {
            self.locationManagerInstance.stopUpdatingLocation();
            self.locatingEnabled = false;
            return true;
        }
        return false;
    }
    
}
