//
//  DatabaseManager.swift
//  strv-test
//
//  Created by Milan Horvatovic on 30/04/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import Foundation;
import CoreData;

let _kDatabaseManagerCheckContextSaveObjectsCount:Int = 100;

class DatabaseManager: NSObject {
    
//    private var _dbObjectModel: NSManagedObjectModel?;
//    private var dbObjectModel: NSManagedObjectModel? {
//        get {
//            if (self._dbObjectModel == nil) {
//                if let path:String = NSBundle.mainBundle().pathForResource("DataModel.momd/DataModel", ofType: "mom") {
//                    if let momURL:NSURL = NSURL.fileURLWithPath(path) {
//                        self._dbObjectModel = NSManagedObjectModel(contentsOfURL: momURL);
//                    }
//                }
//            }
//            return self._dbObjectModel;
//        }
//        set {
//            self._dbObjectModel = newValue;
//        }
//    }
    lazy private var dbObjectModel: NSManagedObjectModel? = {
        var dbObjectModel: NSManagedObjectModel?;
        if let path: String = NSBundle.mainBundle().pathForResource("DataModel.momd/DataModel", ofType: "mom") {
            if let momURL:NSURL = NSURL.fileURLWithPath(path) {
                dbObjectModel = NSManagedObjectModel(contentsOfURL: momURL);
            }
        }
        return dbObjectModel;
    }();
    
//    private var _mainObjectContext: NSManagedObjectContext?;
//    private(set) var mainObjectContext: NSManagedObjectContext? {
//        get {
//            if (self._mainObjectContext == nil) {
//                if (self.writeObjectContext != nil) {
//                    self._mainObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType);
//                    self._mainObjectContext?.parentContext = self.writeObjectContext;
//                    self._mainObjectContext?.undoManager = nil;
//                }
//            }
//            return self._mainObjectContext;
//        }
//        set {
//            self._mainObjectContext = newValue;
//        }
//    }
    private(set) lazy var mainObjectContext: NSManagedObjectContext? = {
        var mainObjectContext: NSManagedObjectContext?;
        if (self.writeObjectContext != nil) {
            mainObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType);
            mainObjectContext?.parentContext = self.writeObjectContext;
            mainObjectContext?.undoManager = nil;
        }
        return mainObjectContext;
    }();

//    private var _writeObjectContext: NSManagedObjectContext?;
//    private var writeObjectContext: NSManagedObjectContext? {
//        get {
//            if (self._writeObjectContext == nil) {
//                if (self.dbStoreCoordinator != nil) {
//                    self._writeObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType);
//                    self._writeObjectContext?.persistentStoreCoordinator = self.dbStoreCoordinator;
//                }
//            }
//            return self._writeObjectContext;
//        }
//        set {
//            self._writeObjectContext = newValue;
//        }
//    }
    lazy private var writeObjectContext: NSManagedObjectContext? = {
        var writeObjectContext: NSManagedObjectContext?;
        if (self.dbStoreCoordinator != nil) {
            writeObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType);
            writeObjectContext?.persistentStoreCoordinator = self.dbStoreCoordinator;
        }
        return writeObjectContext;
    }();
    
//    private var _dbStoreCoordinator: NSPersistentStoreCoordinator?;
//    private var dbStoreCoordinator: NSPersistentStoreCoordinator? {
//        get {
//            if (self._dbStoreCoordinator == nil) {
//                var path:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!.stringByAppendingPathComponent("Databases");
//                let fileManager: NSFileManager = NSFileManager.defaultManager();
//                if (fileManager.isReadableFileAtPath(path) == false) {
//                    fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil);
//                }
//                
//                if let storeURL = NSURL.fileURLWithPath(path.stringByAppendingPathComponent("datastorage_V1.sqlite")) {
//                    
//                    let options:[NSObject: AnyObject] = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(bool: true), NSInferMappingModelAutomaticallyOption: NSNumber(bool: true)];
//                    
//                    var error: NSError?;
//                    
//                    if (self.dbObjectModel != nil) {
//                        self._dbStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.dbObjectModel!);
//                        if (self._dbStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error) != nil) {
//                            if (error != nil) {
//                                println("Failed to add persistent store to store coordinator");
//                                if (error != nil) {
//                                    println("\tError \(error!.userInfo)");
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            return self._dbStoreCoordinator;
//        }
//        set {
//            self._dbStoreCoordinator = newValue;
//        }
//    }
    lazy private var dbStoreCoordinator: NSPersistentStoreCoordinator? = {
        var dbStoreCoordinator: NSPersistentStoreCoordinator?;
        
        var path:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!.stringByAppendingPathComponent("Databases");
        let fileManager: NSFileManager = NSFileManager.defaultManager();
        if (fileManager.isReadableFileAtPath(path) == false) {
            fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil);
        }
        
        if let storeURL = NSURL.fileURLWithPath(path.stringByAppendingPathComponent("datastorage_V1.sqlite")) {
            
            if (fileManager.fileExistsAtPath(storeURL.path!) == false) {
                var error: NSError?;
                
                if let sqliteSource: String = NSBundle.mainBundle().pathForResource("datastorage_V1", ofType: "sqlite") {
                    let sqliteDestination: String = path.stringByAppendingPathComponent("datastorage_V1.sqlite");
                    if (fileManager.copyItemAtPath(sqliteSource, toPath: sqliteDestination, error: &error) == false) {
                        println("Failed to copy sqlite");
                        if (error != nil) {
                            println("\tError \(error!.userInfo)");
                            abort();
                        }
                    }
                }
                
                if let shmSource: String = NSBundle.mainBundle().pathForResource("datastorage_V1", ofType: "sqlite-shm") {
                    let shmDestination: String! = path.stringByAppendingPathComponent("datastorage_V1.sqlite-shm");
                    if (fileManager.copyItemAtPath(shmSource, toPath: shmDestination, error: &error) == false) {
                        println("Failed to copy sqlite-shm");
                        if (error != nil) {
                            println("\tError \(error!.userInfo)");
                            abort();
                        }
                    }
                }
                
                if let walSource: String = NSBundle.mainBundle().pathForResource("datastorage_V1", ofType: "sqlite-wal") {
                    let walDestination: String! = path.stringByAppendingPathComponent("datastorage_V1.sqlite-wal");
                    if (fileManager.copyItemAtPath(walSource, toPath: walDestination, error: &error) == false) {
                        println("Failed to copy sqlite-wal");
                        if (error != nil) {
                            println("\tError \(error!.userInfo)");
                            abort();
                        }
                    }
                }
            }
            
            let options:[NSObject: AnyObject] = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(bool: true), NSInferMappingModelAutomaticallyOption: NSNumber(bool: true)];
            
            var error: NSError?;
            
            if (self.dbObjectModel != nil) {
                dbStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.dbObjectModel!);
                if (dbStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error) != nil) {
                    if (error != nil) {
                        println("Failed to add persistent store to store coordinator");
                        if (error != nil) {
                            println("\tError \(error!.userInfo)");
                        }
                    }
                }
            }
        }
        return dbStoreCoordinator;
    }();
    
    class var sharedInstance: DatabaseManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0;
            static var instance: DatabaseManager? = nil;
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DatabaseManager();
        }
        return Static.instance!
    }
    
    override init() {
        super.init();
    }
    
    //  MARK: Public
    func createDatabaseContext() -> NSManagedObjectContext? {
        var context: NSManagedObjectContext?;
        SwiftTryCatch.try({ () -> Void in
            if (self.dbStoreCoordinator != nil) {
                context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType);
                context?.parentContext = self.mainObjectContext;
                context?.undoManager = nil;
            }
        }, catch: { (error) -> Void in
            println("\(error.description)")
        }) { () -> Void in
            
        }
        return context;
    }
    
    func checkSaveDatabaseContext(context: NSManagedObjectContext, limit: Int) -> Void {
        var limitObject:Int = limit;
        if (limitObject <= 0 || limitObject == NSNotFound) {
            limitObject = _kDatabaseManagerCheckContextSaveObjectsCount;
        }
        if (context.hasChanges == true && (context.updatedObjects.count + context.insertedObjects.count + context.deletedObjects.count) >= limit) {
            self.saveDatabaseContext(context);
//            context.reset();
        }
    }
    
    func saveDatabaseContext(context: NSManagedObjectContext) -> Void {
        if (context.hasChanges) {
            context.performBlockAndWait({ () -> Void in
                var error:NSError?;
                if (context.save(&error) == false) {
                    println("Failed to save to data store");
                    if (error != nil) {
                        println("\tError: \n\t\(error!.localizedDescription) \n\t\(error!.userInfo)");
                    }
                }
                
                if (self.mainObjectContext?.hasChanges == true) {
                    self.mainObjectContext?.performBlock({ () -> Void in
                        var error:NSError?;
                        if (self.mainObjectContext!.save(&error) == false) {
                            if (error != nil) {
                                println("\tError: \(error!.userInfo)");
                            }
                        }
                        
                        if (self.writeObjectContext?.hasChanges == true) {
                            self.writeObjectContext?.performBlock({ () -> Void in
                                var error:NSError?;
                                if (self.writeObjectContext!.save(&error) == false) {
                                    if (error != nil) {
                                        println("\tError: \(error!.userInfo)");
                                    }
                                }
                            });
                        }
                    });
                }
            });
        }
    }
    
}
