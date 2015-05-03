//
//  CDForecast.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation
import CoreData

@objc(CDForecast)
class CDForecast: NSManagedObject {

    @NSManaged var temperature: NSNumber
    @NSManaged var humidity: NSNumber
    @NSManaged var windSpeed: NSNumber
    @NSManaged var windDirection: NSNumber
    @NSManaged var pressure: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var weatherState: String
    @NSManaged var precipitation: NSNumber
    @NSManaged var weatherDescription: String
    @NSManaged var weatherId: NSNumber
    @NSManaged var city: CDCity

}
