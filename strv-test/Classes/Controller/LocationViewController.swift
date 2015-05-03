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
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil);
        controller.searchResultsUpdater = self;
        controller.delegate = self;
        controller.dimsBackgroundDuringPresentation = false;
        controller.searchBar.sizeToFit();
        controller.searchBar.barTintColor = UIColor.whiteColor();
        controller.searchBar.backgroundColor = UIColor.clearColor();
//        controller.searchBar.text
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
    lazy var searchFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "City");
        
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true);
        fetchRequest.sortDescriptors = [primarySortDescriptor];
        
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
        if (self.searchFetchedResultsController.performFetch(&error) == false) {
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
                            LoaderManager.sharedInstance.loadCurrentWeatherWithPosition(list.city.locationLatitude.doubleValue, longitude: list.city.locationLongitude.doubleValue, successHandler: { (request, response, success) -> Void in
                                
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
            if let sections = self.searchFetchedResultsController.sections {
                return sections.count;
            }
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
            if let sections = self.searchFetchedResultsController.sections {
                let currentSection = sections[section] as! NSFetchedResultsSectionInfo
                return currentSection.numberOfObjects
            }
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
        self.tableView?.reloadData();
    }
    
    func willDismissSearchController(searchController: UISearchController) {
//        self.tableView?.reloadData();
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None;
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        self.tableView?.reloadData();
    }
    
    //  MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let fetchRequest: NSFetchRequest = self.searchFetchedResultsController.fetchRequest;
        var predicate: NSPredicate? = nil;
        if (searchController.searchBar.text.isEmpty) {
            
        }
        else {
            var normalized = NSMutableString(string: searchController.searchBar.text) as CFMutableString;
            CFStringNormalize(normalized, CFStringNormalizationForm.D);
            CFStringFold(normalized, CFStringCompareFlags.CompareCaseInsensitive | CFStringCompareFlags.CompareDiacriticInsensitive | CFStringCompareFlags.CompareWidthInsensitive, nil);
            let search: String = normalized as String;
            predicate = NSPredicate(format: "search BEGINSWITH %@", search);
        }
        fetchRequest.predicate = predicate;
        var error: NSError? = nil
        if (self.searchFetchedResultsController.performFetch(&error) == false) {
            print("An error occurred: \(error?.localizedDescription)");
        }
        self.tableView?.reloadData();
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
            if let city: CDCity = self.searchFetchedResultsController.objectAtIndexPath(indexPath) as? CDCity {
                var list: CDList? = city.list;
                if (list == nil) {
                    let context: NSManagedObjectContext = DatabaseManager.sharedInstance.createDatabaseContext()!;
                    
                    list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: context) as? CDList;
                    list?.city = context.objectWithID(city.objectID) as! CDCity;
                    
                    DatabaseManager.sharedInstance.saveDatabaseContext(context);
                }
                
                if (list != nil) {
                    LoaderManager.sharedInstance.loadCurrentWeatherWithPosition(list!.city.locationLatitude.doubleValue, longitude: list!.city.locationLongitude.doubleValue, successHandler: { (request, response, success) -> Void in

                    }, failuerHandler: { (error) -> Void in
                        println("Error \(error)");
                    });
                }
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true);
            self.searchController.active = false;
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true);
        }
    }

    //  MARK: Private
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if (self.searchController.active) {
            if let city: CDCity = self.searchFetchedResultsController.objectAtIndexPath(indexPath) as? CDCity {
                let value: NSString = NSString(format: "%@, %@", city.name, city.country);
                var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: value as String);
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0), range: NSMakeRange(0, value.length));
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNova-Semibold", size: 16)!, range: value.rangeOfString(city.name));
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNova-Light", size: 16)!, range: value.rangeOfString(city.country));
                cell.textLabel?.attributedText = attributedString;
            }
        }
        else {
            if let list: CDList = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDList {
                let cell: LocationTableViewCell = cell as! LocationTableViewCell;
                
                cell.locationImage?.hidden = !list.located.boolValue;
                var city: CDCity? = list.city;
                if (city != nil) {
                    cell.nameLabel?.text = city!.name;
                    
                    
                    let currentDate: NSDate = NSDate();
                    let dateFrom: NSDate = NSDate(timeIntervalSince1970: currentDate.timeIntervalSince1970 - (currentDate.timeIntervalSince1970 % 86400) - 1);
                    let dateTo: NSDate = NSDate(timeIntervalSince1970: currentDate.timeIntervalSince1970 - (currentDate.timeIntervalSince1970 % 86400) + 86400);
                    let dateFromPredicate: NSPredicate = NSPredicate(format: "date > %@", dateFrom);
                    let dateToPredicate: NSPredicate = NSPredicate(format: "date < %@", dateTo);
                    let compoundPredicate: NSPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([dateFromPredicate, dateToPredicate]);
                    
                    let forecasts = city?.forecasts.filteredSetUsingPredicate(compoundPredicate);
                    if let forecast: CDForecast = forecasts!.first as? CDForecast {
                        if let weatherImage = forecast.weatherStateImageName() {
                            cell.weatherImageView?.image = UIImage(named: weatherImage);
                        }
                        cell.temperatureLabel?.text = String(format: "%.1f °", forecast.temperature.doubleValue - 273.15);
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
