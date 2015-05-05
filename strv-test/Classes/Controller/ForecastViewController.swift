//
//  ForecastViewController.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit;
import CoreData;

class ForecastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak private var tableView: UITableView?;
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Forecast");
        
        fetchRequest.returnsObjectsAsFaults = false;
        
        let currentDate: NSDate = NSDate();
        let locatedPredicate: NSPredicate = NSPredicate(format: "city.list.located = %@", NSNumber(bool: true));
        let identifierPredicate: NSPredicate = NSPredicate(format: "identifier > %@", NSNumber(int: 0));
        let currentPredicate: NSPredicate = NSPredicate(format: "current = %@", NSNumber(bool: false));
        let datePredicate: NSPredicate = NSPredicate(format: "date >= %@", NSDate(timeIntervalSince1970: currentDate.timeIntervalSince1970 - (currentDate.timeIntervalSince1970 % 86400)));
        let compoundPredicate: NSPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([locatedPredicate, identifierPredicate, currentPredicate, datePredicate]);
        fetchRequest.predicate = compoundPredicate;
        
        let primarySortDescriptor = NSSortDescriptor(key: "date", ascending: true);
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
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

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var error: NSError? = nil
        if (self.fetchedResultsController.performFetch(&error) == false) {
            print("An error occurred: \(error?.localizedDescription)");
        }
        self.tableView?.reloadData();
        
        if (self.tableView != nil && self.tableView(self.tableView!, numberOfRowsInSection: 0) > 0) {
            let indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0);
            if let forecast: CDForecast = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDForecast {
                var city: CDCity? = forecast.city;
                if (city != nil) {
                    self.navigationItem.title = city?.nameWithCountry();
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        if (self.navigationItem.title == nil) {
            self.navigationItem.title = "Forecast";
        }
        
        self.tableView?.reloadData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    //  MARK: - Delegate
    //  MARK: Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections.count;
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ForecastTableViewCell = tableView.dequeueReusableCellWithIdentifier("ForecastCellIdentifier") as! ForecastTableViewCell;
        
        self.configureCell(cell, atIndexPath: indexPath);
        
        return cell;
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    //  MARK: NSFetchedResultsControllerDelegate
    /* called first
    begins update to `UITableView`
    ensures all updates are animated simultaneously */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView!.beginUpdates();
    }
    
    /* called:
    - when a new model is created
    - when an existing model is updated
    - when an existing model is deleted */
    func controller(controller: NSFetchedResultsController, didChangeObject object: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            self.tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
        case NSFetchedResultsChangeType.Update:
            if let cell = self.tableView!.cellForRowAtIndexPath(indexPath!) as? ForecastTableViewCell {
                self.configureCell(cell, atIndexPath: indexPath!);
            }
//            self.tableView!.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
        case NSFetchedResultsChangeType.Move:
            self.tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
            self.tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
        case NSFetchedResultsChangeType.Delete:
            self.tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade);
        default:
            return
        }
    }
    
    /* called last
    tells `UITableView` updates are complete */
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView!.endUpdates();
    }
    
    //  MARK: Private
    func configureCell(cell: ForecastTableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let forecast: CDForecast = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDForecast {
            if let weatherImage = forecast.weatherStateImageName() {
                cell.weatherImageView?.image = UIImage(named: weatherImage);
            }
            if let temperature: String = forecast.temperatureString(1) {
                cell.temperatureLabel?.text = temperature;
            }
            cell.weatherConditionLabel?.text = forecast.weatherState;
            
            let dateFormater: NSDateFormatter = NSDateFormatter();
            dateFormater.dateFormat = "EEEE";
            cell.nameLabel?.text = dateFormater.stringFromDate(forecast.date);
        }
    }
    
}
