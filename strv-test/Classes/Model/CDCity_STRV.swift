//
//  CDCity_STRV.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation

extension CDCity {
    
    func nameWithCountry() -> String {
        var location: String = self.name;
        if let country = self.country {
            location += ", " + country;
        }
        return location;
    }
    
    override func willChangeValueForKey(key: String) {
        super.willChangeValueForKey(key);
        
        if (self.deleted == false) {
            if (self.forecasts.count > 0) {
                for forecast in forecasts {
                    forecast.willChangeValueForKey("city");
                }
            }
//            var list: CDList? = self.list;
//            if (list != nil) {
//                list!.willChangeValueForKey("list");
//            }
        }
        
    }
    
    override func didChangeValueForKey(key: String) {
        super.didChangeValueForKey(key);
        
        if (self.deleted == false) {
            if (self.forecasts.count > 0) {
                for forecast in forecasts {
                    forecast.didChangeValueForKey("city");
                }
            }
//            var list: CDList? = self.list;
//            if (list != nil) {
//                list!.didChangeValueForKey("list");
//            }
        }
        
    }
    
}