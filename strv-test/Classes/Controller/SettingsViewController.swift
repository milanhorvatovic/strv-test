//
//  SettingsViewController.swift
//  strv-test
//
//  Created by Milan Horvatovic on 03/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 2;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView? = tableView.dequeueReusableCellWithIdentifier("SettingsHeaderCellIdentifier") as? UIView;
        return header;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SettingsTableViewCell? = nil;
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("UnitsLengthCellIdentifier", forIndexPath: indexPath) as? SettingsTableViewCell;
            var units: CDForecastUnits? = CDForecastUnits(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("LENGTH_UNITS"));
            if (units == nil) {
                units = CDForecastUnits.Metrics;
            }
            
            switch units! {
            case CDForecastUnits.Metrics:
                cell?.unitsLabel?.text = "Meters";
            case CDForecastUnits.Imerial:
                cell?.unitsLabel?.text = "Miles";
            default:
                break;
            }
            
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("UnitsTemperatureCellIdentifier", forIndexPath: indexPath) as? SettingsTableViewCell;
            var units: CDForecastUnits? = CDForecastUnits(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("TEMPERATURE_UNITS"));
            if (units == nil) {
                units = CDForecastUnits.Metrics;
            }
            
            switch units! {
            case CDForecastUnits.Metrics:
                cell?.unitsLabel?.text = "Celsius";
            case CDForecastUnits.Imerial:
                cell?.unitsLabel?.text = "Fahrenheit";
            default:
                break;
            }
            
        default:
            break;
        }
        

        // Configure the cell...

        return cell!;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        switch indexPath.row {
        case 0:
            var units: CDForecastUnits? = CDForecastUnits(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("LENGTH_UNITS"));
            if (units == nil) {
                units = CDForecastUnits.Metrics;
            }
            
            switch units! {
            case CDForecastUnits.Metrics:
                units = CDForecastUnits.Imerial;
            case CDForecastUnits.Imerial:
                units = CDForecastUnits.Metrics;
            default:
                break;
            }
            NSUserDefaults.standardUserDefaults().setInteger(units!.rawValue, forKey: "LENGTH_UNITS");
            
        case 1:
            var units: CDForecastUnits? = CDForecastUnits(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("TEMPERATURE_UNITS"));
            if (units == nil) {
                units = CDForecastUnits.Metrics;
            }
            
            switch units! {
            case CDForecastUnits.Metrics:
                units = CDForecastUnits.Imerial;
            case CDForecastUnits.Imerial:
                units = CDForecastUnits.Metrics;
            default:
                break;
            }
            NSUserDefaults.standardUserDefaults().setInteger(units!.rawValue, forKey: "TEMPERATURE_UNITS");
            
        default:
            break;
        }
        
        tableView.reloadData();
    }

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

}
