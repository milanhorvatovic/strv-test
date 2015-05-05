//
//  LocationViewController.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit;
import CoreData;

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak private var tableView: UITableView?;
    @IBOutlet weak private var addButton: UIButton?;
    
    var cities: [AnyObject]?;
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil);
        controller.searchResultsUpdater = self;
        controller.delegate = self;
        controller.dimsBackgroundDuringPresentation = false;
        controller.searchBar.sizeToFit();
        controller.searchBar.barTintColor = UIColor.whiteColor();
        controller.searchBar.backgroundColor = UIColor.clearColor();
        controller.searchBar.tintColor = UIColor(red: 47.0 / 255.0, green: 145.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0);
        controller.searchBar.setImage(UIImage(named: "Search"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal);
        controller.searchBar.setImage(UIImage(named: "Close"), forSearchBarIcon: UISearchBarIcon.Clear, state: UIControlState.Normal);
        controller.searchBar.setSearchFieldBackgroundImage(UIImage(named: "Search-Input"), forState: UIControlState.Normal);
        controller.searchBar.setValue("Close", forKey: "_cancelButtonText");
        
        self.tableView!.tableHeaderView = controller.searchBar;
        
        return controller;
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "List");
        
        fetchRequest.relationshipKeyPathsForPrefetching = ["city"]
        fetchRequest.returnsObjectsAsFaults = false;
        
        let cityPredicate = NSPredicate(format: "city != nil");
        let cityNamePredicate = NSPredicate(format: "city.name != nil");
        let predicate = NSCompoundPredicate.andPredicateWithSubpredicates([cityPredicate, cityNamePredicate]);
        fetchRequest.predicate = predicate;
        
        let primarySortDescriptor = NSSortDescriptor(key: "located", ascending: false);
        let secondarySortDescriptor = NSSortDescriptor(key: "city.name", ascending: true);
        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor];
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DatabaseManager.sharedInstance.mainObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Location";
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var error: NSError? = nil
        if (self.fetchedResultsController.performFetch(&error) == false) {
            print("An error occurred: \(error?.localizedDescription)");
        }
        self.tableView?.reloadData();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections.first as! NSFetchedResultsSectionInfo
            if (currentSection.numberOfObjects > 0) {
                if let fetchedObjects = self.fetchedResultsController.fetchedObjects {
                    for item in fetchedObjects {
                        if let list: CDList = item as? CDList {
                            LoaderManager.sharedInstance.loadCurrentWeatherWithId(list.city.identifier.integerValue, successHandler: { (request, response, success) -> Void in
                                }, failuerHandler: { (error) -> Void in
                                    println("Error \(error)");
                            });
                        }
                    }
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //  MARK: - Delegate
    //  MARK: Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.searchController.active) {
            return 1;
            /*
            if let sections = self.searchFetchedResultsController.sections {
                return sections.count;
            }
            */
        }
        else {
            if let sections = self.fetchedResultsController.sections {
                return sections.count;
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.active) {
            if let cities = self.cities {
                return count(cities);
            }
            else {
                return 0;
            }
            /*
            if let sections = self.searchFetchedResultsController.sections {
                let currentSection = sections[section] as! NSFetchedResultsSectionInfo
                return currentSection.numberOfObjects
            }
            */
        }
        else {
            if let sections = self.fetchedResultsController.sections {
                let currentSection = sections[section] as! NSFetchedResultsSectionInfo
                return currentSection.numberOfObjects
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.searchController.active) {
            return 44.0;
        }
        else {
            return 87.0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell;
        if (self.searchController.active) {
            cell = tableView.dequeueReusableCellWithIdentifier("SearchCellIdentifier") as! UITableViewCell;
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("LocationCellIdentifier") as! UITableViewCell;
        }
        self.configureCell(cell, atIndexPath: indexPath);
        
        return cell;
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (self.searchController.active) {
            return false;
        }
        else {
            // Return NO if you do not want the specified item to be editable.
            if let list: CDList = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDList {
                return !list.located.boolValue;
            }
            return false;
        }
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete;
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let list: CDList = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDList {
                let context: NSManagedObjectContext = DatabaseManager.sharedInstance.createDatabaseContext()!;
                context.deleteObject(context.objectWithID(list.objectID));
                DatabaseManager.sharedInstance.saveDatabaseContext(context);
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
//        if (self.searchController.active) {
//            return nil;
//        }
//        else {
            let button: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "            ") { (rowAction, indexPath) -> Void in
                tableView.dataSource?.tableView!(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath);
            };
            button.backgroundColor = UIColor(patternImage: UIImage(named: "Delete")!);
            
            return [button];
//        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    //  MARK: UISearchControllerDelegate
    func willPresentSearchController(searchController: UISearchController) {
//        self.tableView?.reloadData();
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        self.addButton?.alpha = 0.0;
        self.tableView?.reloadData();
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        self.addButton?.alpha = 1.0;
//        self.tableView?.reloadData();
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None;
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        self.tableView?.reloadData();
        self.cities = nil;
    }
    
    //  MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if (searchController.searchBar.text.isEmpty) {
            self.cities = nil;
        }
        else {
            LoaderManager.sharedInstance.findCityWithName(searchController.searchBar.text, successHandler: {
                (request, response, success) -> Void in
                
                if let successResponse: NSDictionary = success {
                    if let forecastArray: NSArray = successResponse["list"] as? NSArray {
                        if (forecastArray.count > 0) {
                            self.cities = forecastArray as [AnyObject];
                            
                            self.tableView?.reloadData();
                        }
                        else {
                            self.cities = nil;
                        }
                    }
                    else {
                        self.cities = nil;
                    }
                }
                else {
                    self.cities = nil;
                }
                
                }) { (error) -> Void in
                    println("Error \(error)");
            };
        }
    }

    //  MARK: NSFetchedResultsControllerDelegate
    /* called first
    begins update to `UITableView`
    ensures all updates are animated simultaneously */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if (self.searchController.active) {
        }
        else {
            self.tableView!.beginUpdates();
        }
    }
    
    /* called:
    - when a new model is created
    - when an existing model is updated
    - when an existing model is deleted */
    func controller(controller: NSFetchedResultsController, didChangeObject object: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if (self.searchController.active) {
        }
        else {
            switch type {
            case NSFetchedResultsChangeType.Insert:
                self.tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
            case NSFetchedResultsChangeType.Update:
                if let cell = self.tableView!.cellForRowAtIndexPath(indexPath!) as? LocationTableViewCell {
                    self.configureCell(cell, atIndexPath: indexPath!);
                }
//                self.tableView!.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
            case NSFetchedResultsChangeType.Move:
                self.tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
                self.tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
            case NSFetchedResultsChangeType.Delete:
                self.tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
            default:
                return
            }
        }
    }
    
    /* called last
    tells `UITableView` updates are complete */
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if (self.searchController.active) {
        }
        else {
            self.tableView!.endUpdates();
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.searchController.active) {
            if let cityJSON: NSDictionary = self.cities?[indexPath.row] as? NSDictionary {
                tableView.deselectRowAtIndexPath(indexPath, animated: true);
                self.searchController.active = false;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let cityId: NSNumber? = cityJSON["id"] as? NSNumber;
                    let cityName: String? = cityJSON["name"] as? String;
                    
                    if (cityId != nil && cityName != nil) {
                        var city: CDCity?;
                        
                        if let context: NSManagedObjectContext? = DatabaseManager.sharedInstance.createDatabaseContext() {
                            var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "City");
                            let cityPredicate: NSPredicate = NSPredicate(format: "identifier = %@", cityId!);
                            fetchRequest.predicate = cityPredicate;
                            var error: NSError?;
                            if let cityArray = context?.executeFetchRequest(fetchRequest, error: &error) {
                                if (cityArray.count > 0) {
                                    city = cityArray.first as? CDCity;
                                }
                                
                                if (city == nil) {
                                    city = NSEntityDescription.insertNewObjectForEntityForName("City", inManagedObjectContext: context!) as? CDCity;
                                }
                            }
                            
                            if (city != nil) {
                                city?.identifier = cityId!;
                                if let cityName: String = cityName {
                                    city?.name = cityName;
                                }
                                if let coordinates: NSDictionary = cityJSON["coord"] as? NSDictionary {
                                    if let latitude: NSNumber = coordinates["lat"] as? NSNumber {
                                        city?.locationLatitude = latitude;
                                    }
                                    if let longitude: NSNumber = coordinates["lon"] as? NSNumber {
                                        city?.locationLongitude = longitude;
                                    }
                                }
                                if let country: String = cityJSON["sys"]?["country"] as? String {
                                    city?.country = country;
                                }
                                
                                var list: CDList? = city!.list;
                                if (list == nil) {
                                    list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: context!) as? CDList;
                                    list?.city = city!;
                                }
                            }
                            
                            DatabaseManager.sharedInstance.saveDatabaseContext(context!);
                            
                            LoaderManager.sharedInstance.loadCurrentWeatherWithId(city!.identifier.integerValue, successHandler: { (request, response, success) -> Void in
                                }, failuerHandler: { (error) -> Void in
                                    println("Error \(error)");
                            });
                        }
                    }
                }
            }
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true);
        }
    }

    //  MARK: Private
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if (self.searchController.active) {
//            {"id":2643743,"name":"London","coord":{"lon":-0.12574,"lat":51.50853},"main":{"temp":284.039,"temp_min":284.039,"temp_max":284.039,"pressure":1005.43,"sea_level":1013.25,"grnd_level":1005.43,"humidity":86},"dt":1430852274,"wind":{"speed":7.71,"deg":217.002},"sys":{"country":"GB"},"clouds":{"all":68},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}]}
            if let city: NSDictionary = self.cities?[indexPath.row] as? NSDictionary {
                if let cityName: String = city["name"] as? String {
                    if let cityCountry: String = city["sys"]?["country"] as? String {
                        let value: NSString = cityName + ", " + cityCountry;
                        var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: value as String);
                        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0), range: NSMakeRange(0, value.length));
                        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNova-Semibold", size: 16)!, range: value.rangeOfString(cityName));
                        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNova-Light", size: 16)!, range: value.rangeOfString(cityCountry));
                        cell.textLabel?.attributedText = attributedString;
                    }
                    else {
                        let value: NSString = cityName;
                        var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: value as String);
                        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0), range: NSMakeRange(0, value.length));
                        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNova-Semibold", size: 16)!, range: value.rangeOfString(cityName));
                        cell.textLabel?.attributedText = attributedString;
                    }
                }
            }
        }
        else {
            if let list: CDList = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDList {
                let cell: LocationTableViewCell = cell as! LocationTableViewCell;
                
                cell.locationImage?.hidden = !list.located.boolValue;
                var city: CDCity? = list.city;
                if (city != nil) {
                    cell.nameLabel?.text = city!.name;
                    
                    let currentPredicate: NSPredicate = NSPredicate(format: "current = %@", NSNumber(bool: true));
                    let forecasts = city?.forecasts.filteredSetUsingPredicate(currentPredicate);
                    if let forecast: CDForecast = forecasts!.first as? CDForecast {
                        if let weatherImage = forecast.weatherStateImageName() {
                            cell.weatherImageView?.image = UIImage(named: weatherImage);
                        }
                        if let temperature: String = forecast.temperatureString(1) {
                            cell.temperatureLabel?.text = temperature;
                        }
                        cell.weatherConditionLabel?.text = forecast.weatherState;
                    }
                }
            }
        }
    }
    
    @IBAction func closeButtonEventAction(button: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func addButtonEventAction(button: UIButton) {
        self.searchController.active = true;
        self.searchController.searchBar.becomeFirstResponder();
    }
    
}
