//
//  CDList_STRV.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation

extension CDList {
    
    override func willChangeValueForKey(key: String) {
        super.willChangeValueForKey(key);
        
        if (self.deleted == false) {
            var city: CDCity? = self.city;
            if (city != nil) {
                city!.willChangeValueForKey("list");
            }
        }
        
    }
    
    override func didChangeValueForKey(key: String) {
        super.didChangeValueForKey(key);
        
        if (self.deleted) {
            var city: CDCity? = self.city;
            if (city != nil) {
                city!.didChangeValueForKey("list");
            }
        }
        
    }
    
}