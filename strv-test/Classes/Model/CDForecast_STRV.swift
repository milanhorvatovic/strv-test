//
//  CDForecastExtension.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation

enum CDForecastUnits : Int {
    case Metrics
    case Imerial
}

extension CDForecast {
    
    func weatherStateImageName() -> String? {
        var weatherDescription: String? = self.weatherDescription;
        if (weatherDescription != nil) {
            if ((weatherDescription?.lowercaseString.rangeOfString("thunderstorm")) != nil) {
                return "Lightning";
            }
            else if ((weatherDescription?.lowercaseString.rangeOfString("cloud")) != nil) {
                return "Cloudy";
            }
            else if ((weatherDescription?.lowercaseString.rangeOfString("wind")) != nil) {
                return "Wind";
            }
            else {
                return "Sun";
            }
        }
        return nil;
    }
    
    func temperatureString(precision: Int) -> String? {
        let format: String = String(format: "%%.%df", precision);
        
        var units: CDForecastUnits? = CDForecastUnits(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("TEMPERATURE_UNITS"));
        if (units == nil) {
            units = CDForecastUnits.Metrics;
        }
        switch units! {
        case .Metrics:
            return String(format: String(format: "%@ °C", format), self.temperature.doubleValue - 273.15);
        case .Imerial:
            return String(format: String(format: "%@ °F", format), (self.temperature.doubleValue - 273.15) * 1.8000 + 32.00);
        default:
            return nil;
        }
    }
    
    func windSpeedString(precision: Int) -> String? {
        let format: String = String(format: "%%.%df", precision);
        
        var units: CDForecastUnits? = CDForecastUnits(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("LENGTH_UNITS"));
        if (units == nil) {
            units = CDForecastUnits.Metrics;
        }
        switch units! {
        case .Metrics:
            return String(format: String(format: "%@ km/h", format), self.windSpeed.doubleValue * 3.6);
        case .Imerial:
            return String(format: String(format: "%@ mph", format), self.windSpeed.doubleValue * 2.23694);
        default:
            return nil;
        }
    }
    
    func windDirectionString() -> String? {
        if (self.windDirection.doubleValue > 348.75 && self.windDirection.doubleValue < 11.25) {
            return "N";
        }
        else if (self.windDirection.doubleValue > 11.25 && self.windDirection.doubleValue < 33.75) {
            return "NNE";
        }
        else if (self.windDirection.doubleValue > 33.75 && self.windDirection.doubleValue < 56.25) {
            return "NE";
        }
        else if (self.windDirection.doubleValue > 56.25 && self.windDirection.doubleValue < 78.75) {
            return "ENE";
        }
        else if (self.windDirection.doubleValue > 78.75 && self.windDirection.doubleValue < 101.25) {
            return "E";
        }
        else if (self.windDirection.doubleValue > 101.25 && self.windDirection.doubleValue < 123.75) {
            return "ESE";
        }
        else if (self.windDirection.doubleValue > 123.75 && self.windDirection.doubleValue < 146.25) {
            return "SE";
        }
        else if (self.windDirection.doubleValue > 146.25 && self.windDirection.doubleValue < 168.75) {
            return "SSE";
        }
        else if (self.windDirection.doubleValue > 168.75 && self.windDirection.doubleValue < 191.25) {
            return "S";
        }
        else if (self.windDirection.doubleValue > 191.25 && self.windDirection.doubleValue < 213.75) {
            return "SSW";
        }
        else if (self.windDirection.doubleValue > 213.75 && self.windDirection.doubleValue < 236.25) {
            return "SW";
        }
        else if (self.windDirection.doubleValue > 236.25 && self.windDirection.doubleValue < 258.75) {
            return "WSW";
        }
        else if (self.windDirection.doubleValue > 258.75 && self.windDirection.doubleValue < 281.25) {
            return "W";
        }
        else if (self.windDirection.doubleValue > 281.25 && self.windDirection.doubleValue < 303.75) {
            return "WNW";
        }
        else if (self.windDirection.doubleValue > 303.75 && self.windDirection.doubleValue < 326.25) {
            return "NW";
        }
        else if (self.windDirection.doubleValue > 326.25 && self.windDirection.doubleValue < 348.75) {
            return "NNW";
        }
        else {
            return "-";
        }
    }
    
}