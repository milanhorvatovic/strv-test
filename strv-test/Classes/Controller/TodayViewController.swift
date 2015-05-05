//
//  FirstViewController.swift
//  strv-test
//
//  Created by Milan Horvatovic on 28/04/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit;
import CoreLocation;
import CoreData;

class TodayViewController: UIViewController, LocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak private var weatherImageView: UIImageView?;
    @IBOutlet weak private var locationImageView: UIImageView?;
    @IBOutlet weak private var locationLabel: UILabel?;
    @IBOutlet weak private var weatherLabel: UILabel?;
    @IBOutlet weak private var temperatureLabel: UILabel?;
    
    @IBOutlet weak private var humidityLabel: UILabel?;
    @IBOutlet weak private var rainLabel: UILabel?;
    @IBOutlet weak private var pressureLabel: UILabel?;
    @IBOutlet weak private var windSpeedLabel: UILabel?;
    @IBOutlet weak private var windDirectionLabel: UILabel?;
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Forecast");
        
        let cityPredicate: NSPredicate = NSPredicate(format: "city.list.located = %@", NSNumber(bool: true));
        let currentPredicate: NSPredicate = NSPredicate(format: "current = %@", NSNumber(bool: true));
        let compoundPredicate: NSPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([cityPredicate, currentPredicate]);
        fetchRequest.predicate = compoundPredicate;
        
        let primarySortDescriptor = NSSortDescriptor(key: "date", ascending: false);
        fetchRequest.sortDescriptors = [primarySortDescriptor];
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DatabaseManager.sharedInstance.mainObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil);
        
        frc.delegate = self;
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Today";
        
        LocationManager.sharedInstance.delegate = self;
        
        var error: NSError? = nil
        if (self.fetchedResultsController.performFetch(&error) == false) {
            print("An error occurred: \(error?.localizedDescription)");
        }
        self.reloadData();
        
        self.setNeedsStatusBarAppearanceUpdate();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.reloadData();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        LocationManager.sharedInstance.startLocating();
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        
        LocationManager.sharedInstance.stopLocating();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    //  MARK: - Delegate
    //  MARK: LocationManager
    func locationManager(locationManager: LocationManager, loadLocation: CLLocation) {
        LoaderManager.sharedInstance.loadCurrentWeatherWithPosition(loadLocation.coordinate.latitude, longitude: loadLocation.coordinate.longitude, located: true, successHandler: { (request, response, success) -> Void in
            
            }) { (error) -> Void in
                println("Error \(error)");
        };
        LoaderManager.sharedInstance.loadForecastWeatherWithPosition(loadLocation.coordinate.latitude, longitude: loadLocation.coordinate.longitude, successHandler: { (request, response, success) -> Void in
            
            }) { (error) -> Void in
                println("Error \(error)");
        };
        
        locationManager.stopLocating();
    }
    
    func locationManager(locationManager: LocationManager, didFailWithError: NSError) {
        
    }
    
    //  MARK: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.reloadData();
    }
    
    //  MARK: - Private
    func reloadData() {
        let currentDate: NSDate = NSDate();
        let dateFrom: NSDate = NSDate(timeIntervalSince1970: currentDate.timeIntervalSince1970 - (currentDate.timeIntervalSince1970 % 86400) - 1);
        let dateTo: NSDate = NSDate(timeIntervalSince1970: currentDate.timeIntervalSince1970 - (currentDate.timeIntervalSince1970 % 86400) + 86400);
        
        let forecasts = self.fetchedResultsController.fetchedObjects?.filter {
            if let forecast = $0 as? CDForecast {
                if (forecast.date.compare(dateFrom) == NSComparisonResult.OrderedDescending && forecast.date.compare(dateTo) == NSComparisonResult.OrderedAscending) {
                    return true;
                }
            }
            return false;
        }
        if let forecast: CDForecast = forecasts!.first as? CDForecast {
            self.locationImageView?.hidden = !forecast.city.list.located.boolValue;
            self.locationLabel?.text = forecast.city.nameWithCountry();
            
            if let weatherImage = forecast.weatherStateImageName() {
                self.weatherImageView?.image = UIImage(named: weatherImage + "_Big");
            }
            
            if let temperature: String = forecast.temperatureString(1) {
                self.temperatureLabel?.text = temperature;
            }
            self.weatherLabel?.text = forecast.weatherState;
            self.humidityLabel?.text = String(format: "%.1f %%", forecast.humidity.doubleValue);
            self.rainLabel?.text = String(format: "%.1f mm", forecast.precipitation.doubleValue);
            self.pressureLabel?.text = String(format: "%.1f hPa", forecast.pressure.doubleValue);
            if let windSpeed: String = forecast.windSpeedString(1) {
                self.windSpeedLabel?.text = windSpeed;
            }
            self.windDirectionLabel?.text = forecast.windDirectionString();
        }
    }
    
    @IBAction func shareButtonEventAction(button: UIButton) {
        let text: String = "What was the weather like?";
        let image: UIImage! = self.weatherImageView?.image;
        var items = [text, image];
        let activityController: UIActivityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil);
        activityController.setValue("Weather", forKey: "subject");
        activityController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypeAddToReadingList,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ];
        
        self.presentViewController(activityController, animated: true, completion: nil);
    }
}

