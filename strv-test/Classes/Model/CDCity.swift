//
//  CDCity.swift
//  strv-test
//
//  Created by Milan Horvatovic on 01/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation
import CoreData

@objc(CDCity)
class CDCity: NSManagedObject {

    @NSManaged var country: String?
    @NSManaged var identifier: NSNumber
    @NSManaged var locationLatitude: NSNumber
    @NSManaged var locationLongitude: NSNumber
    @NSManaged var name: String
    @NSManaged var forecasts: NSSet
    @NSManaged var list: CDList

}
