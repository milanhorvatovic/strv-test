//
//  CDList.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation
import CoreData

@objc(CDList)
class CDList: NSManagedObject {

    @NSManaged var selected: NSNumber
    @NSManaged var located: NSNumber
    @NSManaged var city: CDCity

}
