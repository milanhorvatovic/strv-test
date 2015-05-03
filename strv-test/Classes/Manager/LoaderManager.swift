//
//  LoaderManager.swift
//  strv-test
//
//  Created by Milan Horvatovic on 29/04/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit;
import CoreLocation;
import CoreData;

import Alamofire;

class LoaderManager: NSObject {
    
    class var sharedInstance: LoaderManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0;
            static var instance: LoaderManager? = nil;
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LoaderManager();
        }
        return Static.instance!
    }
    
    func loadCurrentLocatedWeatherWithPosition(latitude: CLLocationDegrees, longitude: CLLocationDegrees, successHandler:(request: NSURLRequest, response: NSHTTPURLResponse?, success:NSDictionary?) -> Void, failuerHandler:(error: NSError) -> Void) -> Bool {
        let URL:String = String(format: "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=c5ad4da2f35d924ebf97b74e3e03b511", latitude, longitude);
        Alamofire.request(Alamofire.Method.GET, URL.URLString).responseJSON() {
            (request, response, JSON, error) in
            
            if (error == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    if let successResponse: NSDictionary = JSON as? NSDictionary {
                        if let dateTime: NSNumber = successResponse["dt"] as? NSNumber {
                            var date: NSDate = NSDate(timeIntervalSince1970: dateTime.doubleValue);
                            
                            let cityId: AnyObject? = successResponse["id"];
                            let cityName: AnyObject? = successResponse["name"];
                            //                        println("ID: \(cityId), Name: \(cityName), Date \(date)");
                            
                            if let context: NSManagedObjectContext? = DatabaseManager.sharedInstance.createDatabaseContext() {
                                var todayForecast: CDForecast?;
                                
                                var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Forecast");
                                let datePredicate: NSPredicate = NSPredicate(format: "date = %@", date);
                                var cityPredicate: NSPredicate = NSPredicate(format: "city.identifier = %@", successResponse["id"] as! NSNumber);
                                let compoundPredicate: NSPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([datePredicate, cityPredicate]);
                                fetchRequest.predicate = compoundPredicate;
                                
                                var error: NSError?;
                                if let todayForecastArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                    todayForecast = todayForecastArray.first as? CDForecast;
                                }
                                if (error != nil) {
                                    if (error != nil) {
                                        println("\tError \(error!.userInfo)");
                                    }
                                }
                                
                                if (todayForecast == nil) {
                                    todayForecast = NSEntityDescription.insertNewObjectForEntityForName("Forecast", inManagedObjectContext: context!) as? CDForecast;
                                    todayForecast?.date = date;
                                }
                                if let temperature: NSNumber = successResponse["main"]?["temp"] as? NSNumber {
                                    todayForecast?.temperature = temperature;
                                }
                                if let humidity: NSNumber = successResponse["main"]?["humidity"] as? NSNumber {
                                    todayForecast?.humidity = humidity;
                                }
                                if let pressure: NSNumber = successResponse["main"]?["pressure"] as? NSNumber {
                                    todayForecast?.pressure = pressure;
                                }
                                if let windSpeed: NSNumber = successResponse["wind"]?["speed"] as? NSNumber {
                                    todayForecast?.windSpeed = windSpeed;
                                }
                                if let windDirection: NSNumber = successResponse["wind"]?["deg"] as? NSNumber {
                                    todayForecast?.windDirection = windDirection;
                                }
                                if let weatherArray: NSArray = successResponse["weather"] as? NSArray {
                                    if let weatherDictionary: NSDictionary = weatherArray.firstObject as? NSDictionary {
                                        if let id: NSNumber = weatherDictionary["id"] as? NSNumber {
                                            todayForecast?.weatherId = id;
                                        }
                                        if let state: String = weatherDictionary["main"] as? String {
                                            todayForecast?.weatherState = state;
                                        }
                                        if let description: String = weatherDictionary["description"] as? String {
                                            todayForecast?.weatherDescription = description;
                                        }
                                    }
                                }
                                if let rain: NSNumber = successResponse["rain"]?["3h"] as? NSNumber {
                                    todayForecast?.precipitation = rain;
                                }
                                
                                fetchRequest = NSFetchRequest(entityName: "City");
                                cityPredicate = NSPredicate(format: "identifier = %@", successResponse["id"] as! NSNumber);
                                fetchRequest.predicate = cityPredicate;
                                
                                if let cityArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                    if (cityArray.count > 0) {
                                        fetchRequest = NSFetchRequest(entityName: "List");
                                        let listPredicate: NSPredicate = NSPredicate(format: "located = %@", NSNumber(bool: true));
                                        fetchRequest.predicate = listPredicate;
                                        if let listArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                            for list in listArray {
                                                var listObject: CDList = list as! CDList;
                                                listObject.located = NSNumber(bool: false);
                                            }
                                        }
                                        
                                        var city: CDCity = cityArray.first as! CDCity;
                                        var list: CDList? = city.list;
                                        if (list == nil) {
                                            list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: context!) as? CDList;
                                            list?.city = city;
                                        }
                                        list!.located = NSNumber(bool: true);
                                        
                                        todayForecast?.city = city;
                                    }
                                }
                                if (error != nil) {
                                    if (error != nil) {
                                        println("\tError \(error!.userInfo)");
                                    }
                                }
                                
                                DatabaseManager.sharedInstance.saveDatabaseContext(context!);
                            }
                        }
                    }
                });
                successHandler(request: request, response: response, success: JSON as? NSDictionary);
            }
            else {
                failuerHandler(error: error!);
            }
        };
        return false;
    }
    
    func loadCurrentWeatherWithPosition(latitude: CLLocationDegrees, longitude: CLLocationDegrees, successHandler:(request: NSURLRequest, response: NSHTTPURLResponse?, success:NSDictionary?) -> Void, failuerHandler:(error: NSError) -> Void) -> Bool {
        let URL:String = String(format: "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=c5ad4da2f35d924ebf97b74e3e03b511", latitude, longitude);
        Alamofire.request(Alamofire.Method.GET, URL.URLString).responseJSON() {
            (request, response, JSON, error) in
            
            if (error == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    if let successResponse: NSDictionary = JSON as? NSDictionary {
                        if let dateTime: NSNumber = successResponse["dt"] as? NSNumber {
                            var date: NSDate = NSDate(timeIntervalSince1970: dateTime.doubleValue);
                            
                            let cityId: AnyObject? = successResponse["id"];
                            let cityName: AnyObject? = successResponse["name"];
                            //                        println("ID: \(cityId), Name: \(cityName), Date \(date)");
                            
                            if let context: NSManagedObjectContext? = DatabaseManager.sharedInstance.createDatabaseContext() {
                                var todayForecast: CDForecast?;
                                
                                var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Forecast");
                                let datePredicate: NSPredicate = NSPredicate(format: "date = %@", date);
                                var cityPredicate: NSPredicate = NSPredicate(format: "city.identifier = %@", successResponse["id"] as! NSNumber);
                                let compoundPredicate: NSPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([datePredicate, cityPredicate]);
                                fetchRequest.predicate = compoundPredicate;
                                
                                var error: NSError?;
                                if let todayForecastArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                    todayForecast = todayForecastArray.first as? CDForecast;
                                }
                                if (error != nil) {
                                    if (error != nil) {
                                        println("\tError \(error!.userInfo)");
                                    }
                                }
                                
                                if (todayForecast == nil) {
                                    todayForecast = NSEntityDescription.insertNewObjectForEntityForName("Forecast", inManagedObjectContext: context!) as? CDForecast;
                                    todayForecast?.date = date;
                                }
                                if let temperature: NSNumber = successResponse["main"]?["temp"] as? NSNumber {
                                    todayForecast?.temperature = temperature;
                                }
                                if let humidity: NSNumber = successResponse["main"]?["humidity"] as? NSNumber {
                                    todayForecast?.humidity = humidity;
                                }
                                if let pressure: NSNumber = successResponse["main"]?["pressure"] as? NSNumber {
                                    todayForecast?.pressure = pressure;
                                }
                                if let windSpeed: NSNumber = successResponse["wind"]?["speed"] as? NSNumber {
                                    todayForecast?.windSpeed = windSpeed;
                                }
                                if let windDirection: NSNumber = successResponse["wind"]?["deg"] as? NSNumber {
                                    todayForecast?.windDirection = windDirection;
                                }
                                if let weatherArray: NSArray = successResponse["weather"] as? NSArray {
                                    if let weatherDictionary: NSDictionary = weatherArray.firstObject as? NSDictionary {
                                        if let id: NSNumber = weatherDictionary["id"] as? NSNumber {
                                            todayForecast?.weatherId = id;
                                        }
                                        if let state: String = weatherDictionary["main"] as? String {
                                            todayForecast?.weatherState = state;
                                        }
                                        if let description: String = weatherDictionary["description"] as? String {
                                            todayForecast?.weatherDescription = description;
                                        }
                                    }
                                }
                                if let rain: NSNumber = successResponse["rain"]?["3h"] as? NSNumber {
                                    todayForecast?.precipitation = rain;
                                }
                                
                                fetchRequest = NSFetchRequest(entityName: "City");
                                cityPredicate = NSPredicate(format: "identifier = %@", successResponse["id"] as! NSNumber);
                                fetchRequest.predicate = cityPredicate;
                                
                                if let cityArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                    if (cityArray.count > 0) {
                                        var city: CDCity = cityArray.first as! CDCity;
                                        var list: CDList? = city.list;
                                        if (list == nil) {
                                            list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: context!) as? CDList;
                                            list?.city = city;
                                        }
                                        
                                        todayForecast?.city = city;
                                    }
                                }
                                if (error != nil) {
                                    if (error != nil) {
                                        println("\tError \(error!.userInfo)");
                                    }
                                }
                                
                                DatabaseManager.sharedInstance.saveDatabaseContext(context!);
                            }
                        }
                    }
                });
                successHandler(request: request, response: response, success: JSON as? NSDictionary);
            }
            else {
                failuerHandler(error: error!);
            }
        };
        return false;
    }
    
    func loadForecastWeatherWithPosition(latitude: CLLocationDegrees, longitude: CLLocationDegrees, successHandler:(request: NSURLRequest, response: NSHTTPURLResponse?, success:NSDictionary?) -> Void, failuerHandler:(error: NSError) -> Void) -> Bool {
        let URL: String = String(format: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=5&APPID=c5ad4da2f35d924ebf97b74e3e03b511&mode=json", latitude, longitude);
        Alamofire.request(Alamofire.Method.GET, URL.URLString).responseJSON() {
            (request, response, JSON, error) in
            
            if (error == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    if let successResponse: NSDictionary = JSON as? NSDictionary {
                        let cityId: AnyObject? = successResponse["city"]?["id"];
                        let cityName: AnyObject? = successResponse["city"]?["name"];
                        //                    println("ID: \(cityId), Name: \(cityName)");
                        
                        if let cityJSON: NSDictionary = successResponse["city"] as? NSDictionary {
                            if let cityId: NSNumber = cityJSON["id"] as? NSNumber {
                                if let context: NSManagedObjectContext? = DatabaseManager.sharedInstance.createDatabaseContext() {
                                    var error: NSError?;
                                    var fetchRequest: NSFetchRequest;
                                    
                                    var city: CDCity?;
                                    
                                    fetchRequest = NSFetchRequest(entityName: "City");
                                    let cityPredicate: NSPredicate = NSPredicate(format: "identifier = %@", cityId);
                                    fetchRequest.predicate = cityPredicate;
                                    if let cityArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                        if (cityArray.count > 0) {
                                            city = cityArray.first as? CDCity;
                                        }
                                    }
                                    
                                    if (city != nil) {
                                        if let forecastArray: NSArray = successResponse["list"] as? NSArray {
                                            for forecastItem in forecastArray {
                                                if let forecastJSON: NSDictionary = forecastItem as? NSDictionary {
                                                    if let dateTime: NSNumber = forecastJSON["dt"] as? NSNumber {
                                                        var date: NSDate = NSDate(timeIntervalSince1970: dateTime.doubleValue);
                                                        
                                                        var forecast: CDForecast?;
                                                        
                                                        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Forecast");
                                                        let datePredicate: NSPredicate = NSPredicate(format: "date = %@", date);
                                                        let cityPredicate: NSPredicate = NSPredicate(format: "city.identifier = %@", cityId);
                                                        let compoundPredicate: NSPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([datePredicate, cityPredicate]);
                                                        fetchRequest.predicate = compoundPredicate;
                                                        
                                                        var error: NSError?;
                                                        if let todayForecastArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                                            forecast = todayForecastArray.first as? CDForecast;
                                                        }
                                                        if (error != nil) {
                                                            if (error != nil) {
                                                                println("\tError \(error!.userInfo)");
                                                            }
                                                        }
                                                        
                                                        if (forecast == nil) {
                                                            forecast = NSEntityDescription.insertNewObjectForEntityForName("Forecast", inManagedObjectContext: context!) as? CDForecast;
                                                            forecast?.date = date;
                                                        }
                                                        if let temperature: NSNumber = forecastJSON["temp"]?["day"] as? NSNumber {
                                                            forecast?.temperature = temperature;
                                                        }
                                                        if let humidity: NSNumber = forecastJSON["humidity"] as? NSNumber {
                                                            forecast?.humidity = humidity;
                                                        }
                                                        if let pressure: NSNumber = forecastJSON["pressure"] as? NSNumber {
                                                            forecast?.pressure = pressure;
                                                        }
                                                        
                                                        if let weatherArray: NSArray = forecastJSON["weather"] as? NSArray {
                                                            if let weatherDictionary: NSDictionary = weatherArray.firstObject as? NSDictionary {
                                                                if let id: NSNumber = weatherDictionary["id"] as? NSNumber {
                                                                    forecast?.weatherId = id;
                                                                }
                                                                if let state: String = weatherDictionary["main"] as? String {
                                                                    forecast?.weatherState = state;
                                                                }
                                                                if let description: String = weatherDictionary["description"] as? String {
                                                                    forecast?.weatherDescription = description;
                                                                }
                                                            }
                                                        }
                                                        
                                                        forecast?.city = city!;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    DatabaseManager.sharedInstance.saveDatabaseContext(context!);
                                }
                            }
                        }
                    }
                });
                successHandler(request: request, response: response, success: JSON as? NSDictionary);
            }
            else {
                failuerHandler(error: error!);
            }
        };
        return false;
    }
    
    func parseCityList() -> Void {
        if let path:String = NSBundle.mainBundle().pathForResource("city-list", ofType: "json") {
            autoreleasepool {
                let jsonData = NSData(contentsOfFile:path, options: .DataReadingMappedIfSafe, error: nil);
                var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray;
                let context = DatabaseManager.sharedInstance.createDatabaseContext()!
                
                var index:Int = 0;
                for city in jsonResult {
                    autoreleasepool {
                        let cityName: NSString = city["name"] as! NSString;
                        let cityCountry: NSString = city["country"] as! NSString;
                        if (cityName.length > 0 && cityCountry.length > 0) {
//                            println("index \(index): \(cityName)");
                            let cityMO: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("City", inManagedObjectContext: context);
                            cityMO.setValue(city["_id"], forKey: "identifier");
                            cityMO.setValue(cityName, forKey: "name");
                            cityMO.setValue(city["country"], forKey: "country");
                            cityMO.setValue((city["coord"] as! Dictionary)["lat"], forKey: "locationLatitude");
                            cityMO.setValue((city["coord"] as! Dictionary)["lon"], forKey: "locationLongitude");
                            var normalized = NSMutableString(string: cityName) as CFMutableString;
                            CFStringNormalize(normalized, CFStringNormalizationForm.D);
                            CFStringFold(normalized, CFStringCompareFlags.CompareCaseInsensitive | CFStringCompareFlags.CompareDiacriticInsensitive | CFStringCompareFlags.CompareWidthInsensitive, nil);
                            cityMO.setValue(normalized, forKey: "search");
                            DatabaseManager.sharedInstance.checkSaveDatabaseContext(context, limit: 10000);
//                            context.reset();
                            index++;
                        }
                    }
                }
                
                DatabaseManager.sharedInstance.saveDatabaseContext(context);
            }
        }
    }
    
}
