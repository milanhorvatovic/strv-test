//
//  CDForecast.swift
//  strv-test
//
//  Created by Milan Horvatovic on 05/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation
import CoreData

@objc(CDForecast)
class CDForecast: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var humidity: NSNumber
    @NSManaged var precipitation: NSNumber
    @NSManaged var pressure: NSNumber
    @NSManaged var temperature: NSNumber
    @NSManaged var weatherDescription: String
    @NSManaged var weatherId: NSNumber
    @NSManaged var weatherState: String
    @NSManaged var windDirection: NSNumber
    @NSManaged var windSpeed: NSNumber
    @NSManaged var current: NSNumber
    @NSManaged var identifier: NSNumber
    @NSManaged var city: CDCity

}
