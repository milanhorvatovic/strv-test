//
//  AppDelegate.swift
//  strv-test
//
//  Created by Milan Horvatovic on 28/04/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit

let _kUserDefaultsKeyImportCityList:String = "IMPORT_CITY_LIST";

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?;


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
        UIApplication.sharedApplication().statusBarHidden = false;
        
        UINavigationBar.appearance().backgroundColor = UIColor.whiteColor();
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "NavigationBar"), forBarMetrics: UIBarMetrics.Default);
        UINavigationBar.appearance().shadowImage = UIImage(named: "NavigationBar-Line");
        
        println("Application path: \(NSBundle.mainBundle().resourcePath)");
        println("Document path: \(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first)");
        
        let tabBarController: UITabBarController = window?.rootViewController as! UITabBarController;
        tabBarController.tabBar.backgroundImage = UIImage(named: "Bar");
        
        let todayItem: UITabBarItem = tabBarController.tabBar.items?.first as! UITabBarItem;
        todayItem.image = UIImage(named: "Today-TabBar");
        todayItem.selectedImage = UIImage(named: "Today-TabBar-Selected");
        let forecastItem: UITabBarItem = tabBarController.tabBar.items?[1] as! UITabBarItem;
        forecastItem.image = UIImage(named: "Forecast-TabBar");
        forecastItem.selectedImage = UIImage(named: "Forecast-TabBar-Selected");
        let settingsItem: UITabBarItem = tabBarController.tabBar.items?[2] as! UITabBarItem;
        settingsItem.image = UIImage(named: "Settings-TabBar");
        settingsItem.selectedImage = UIImage(named: "Settings-TabBar-Selected");
        
        LocationManager.sharedInstance;
        DatabaseManager.sharedInstance;
        
//        if (NSUserDefaults.standardUserDefaults().boolForKey(_kUserDefaultsKeyImportCityList) == false) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
//                LoaderManager.sharedInstance.parseCityList();
//                NSUserDefaults.standardUserDefaults().setBool(true, forKey: _kUserDefaultsKeyImportCityList);
//            });
//        }
        
        return true;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
